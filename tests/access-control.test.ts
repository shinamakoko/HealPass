import { describe, it, expect, beforeEach } from "vitest"

type Principal = string

interface AccessPermission {
  granted: boolean
  timestamp: number
}

interface Record {
  uri: string
  timestamp: number
}

const INVALID = "SP000000000000000000002Q6VF78"

const mockContract = {
  now: 1000,
  accessPermissions: new Map<string, AccessPermission>(),
  patientRecords: new Map<Principal, Record[]>(),

  key(patient: Principal, provider: Principal) {
    return `${patient}::${provider}`
  },

  grantAccess(patient: Principal, provider: Principal) {
    if (provider === INVALID) return { error: 104 }
    const key = this.key(patient, provider)
    const existing = this.accessPermissions.get(key)
    if (existing?.granted) return { error: 102 }
    this.accessPermissions.set(key, { granted: true, timestamp: this.now++ })
    return { value: true }
  },

  revokeAccess(patient: Principal, provider: Principal) {
    const key = this.key(patient, provider)
    const existing = this.accessPermissions.get(key)
    if (!existing?.granted) return { error: 103 }
    this.accessPermissions.set(key, { granted: false, timestamp: this.now++ })
    return { value: true }
  },

  canAccess(patient: Principal, provider: Principal) {
    const key = this.key(patient, provider)
    return { value: this.accessPermissions.get(key)?.granted ?? false }
  },

  uploadRecord(patient: Principal, uri: string) {
    if (patient === INVALID) return { error: 104 }
    const existing = this.patientRecords.get(patient) || []
    const record: Record = { uri, timestamp: this.now++ }
    this.patientRecords.set(patient, [...existing, record])
    return { value: true }
  },

  getRecords(patient: Principal) {
    return { value: this.patientRecords.get(patient) ?? [] }
  },

  getAccessLog(patient: Principal, provider: Principal) {
    const key = this.key(patient, provider)
    const data = this.accessPermissions.get(key)
    if (!data) return { error: 103 }
    return { value: data }
  }
}

describe("HealPass Access Control Contract", () => {
  const alice = "STALICE123"
  const bob = "STBOB123"
  const mallory = "STMALLORY"

  beforeEach(() => {
    mockContract.now = 1000
    mockContract.accessPermissions = new Map()
    mockContract.patientRecords = new Map()
  })

  it("should grant access to a provider", () => {
    const result = mockContract.grantAccess(alice, bob)
    expect(result).toEqual({ value: true })
    expect(mockContract.accessPermissions.get(`${alice}::${bob}`)?.granted).toBe(true)
  })

  it("should not allow duplicate access grants", () => {
    mockContract.grantAccess(alice, bob)
    const result = mockContract.grantAccess(alice, bob)
    expect(result).toEqual({ error: 102 })
  })

  it("should revoke access properly", () => {
    mockContract.grantAccess(alice, bob)
    const result = mockContract.revokeAccess(alice, bob)
    expect(result).toEqual({ value: true })
    expect(mockContract.accessPermissions.get(`${alice}::${bob}`)?.granted).toBe(false)
  })

  it("should reject access revocation if not granted", () => {
    const result = mockContract.revokeAccess(alice, mallory)
    expect(result).toEqual({ error: 103 })
  })

  it("should correctly report access rights", () => {
    mockContract.grantAccess(alice, bob)
    expect(mockContract.canAccess(alice, bob)).toEqual({ value: true })
    expect(mockContract.canAccess(alice, mallory)).toEqual({ value: false })
  })

  it("should upload and retrieve records", () => {
    mockContract.uploadRecord(alice, "ipfs://Qm123abc")
    const records = mockContract.getRecords(alice).value
    expect(records.length).toBe(1)
    expect(records[0].uri).toBe("ipfs://Qm123abc")
  })

  it("should reject uploads from zero address", () => {
    const result = mockContract.uploadRecord(INVALID, "ipfs://fail")
    expect(result).toEqual({ error: 104 })
  })

  it("should return full access log details", () => {
    mockContract.grantAccess(alice, bob)
    const log = mockContract.getAccessLog(alice, bob)
    expect(log.value.granted).toBe(true)
  })

  it("should error when accessing missing logs", () => {
    const result = mockContract.getAccessLog(alice, mallory)
    expect(result).toEqual({ error: 103 })
  })
})
