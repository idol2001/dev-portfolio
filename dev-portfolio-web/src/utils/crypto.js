import { JSEncrypt } from 'jsencrypt'
import api from '../api/index'

let publicKey = null
let encryptor = null

// 获取公钥并初始化加密器
async function getEncryptor() {
  if (encryptor && publicKey) return encryptor

  try {
    const res = await api.get('/auth/public-key')
    const keyPem = res.data?.data?.publicKey
    if (!keyPem) throw new Error('Failed to get public key')

    publicKey = keyPem
    encryptor = new JSEncrypt()
    encryptor.setPublicKey(publicKey)
    return encryptor
  } catch (error) {
    console.error('Failed to load public key:', error)
    throw error
  }
}

// 使用 RSA 加密密码，返回 "ENC:<base64>" 格式
export async function encryptPassword(password) {
  const enc = await getEncryptor()
  const encrypted = enc.encrypt(password)
  if (!encrypted) throw new Error('RSA encryption failed')
  return `ENC:${encrypted}`
}

// 清除缓存的公钥（例如 token 过期重新登录时）
export function clearEncryptor() {
  publicKey = null
  encryptor = null
}
