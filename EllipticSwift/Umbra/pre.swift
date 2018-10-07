//
//  pre.swift
//  ReEncryptHealth
//
//  Created by Anton Grigorev on 05.10.2018.
//  Copyright © 2018 Anton Grigorev. All rights reserved.
//

import Foundation
import BigInt

//TODO: - Заново
func assessCfragCorrectness(cfrag: CapsuleFrag, capsule: Capsule) -> Bool _{
    return true
}


class Capsule {
    
    var _umbralParams: UmbralParameters?
    
    var _cfragCorrectnessKeys: [String: UmbralPublicKey?]?
    
    var _pointE: Point?
    var _pointV: Point?
    var _bnSig: BigInt?
    
    var _pointEprime: Point?
    var _pointVprime: Point?
    var _pointNoninteractive: Point?
    
    var _attachedCfrags: Array<Any>?
    
    init(params: UmbralParameters,
         pointE: Point? = nil,
         pointV: Point? = nil,
         bnSig: BigInt? = nil,
         pointEprime: Point? = nil,
         pointVprime: Point? = nil,
         pointNoninteractive: Point? = nil,
         delegatingPubkey: UmbralPublicKey? = nil,
         receivingPubkey: UmbralPublicKey? = nil,
         verifyingPubkey: UmbralPublicKey? = nil) {
        self._umbralParams = params
        
        self._cfragCorrectnessKeys = ["delegating": delegatingPubkey,
                                      "receiving": receivingPubkey,
                                      "verifying": verifyingPubkey]
        
        self._pointE = pointE
        self._pointV = pointV
        self._bnSig = bnSig
        
        self._pointEprime = pointEprime
        self._pointVprime = pointVprime
        self._pointNoninteractive = pointNoninteractive
        
        self._attachedCfrags = Array()
    }
    
    func setCorrectnessKeys(delegating: UmbralPublicKey? = nil,
                            receiving: UmbralPublicKey? = nil,
                            verifying: UmbralPublicKey? = nil) -> (Bool, Bool, Bool) {
        let delegatingKeyDetails = self._setCfragCorrectnessKey(keyType: "delegating",
                                                                key: delegating)
        let receivingKeyDetails = self._setCfragCorrectnessKey(keyType: "receiving",
                                                               key: receiving)
        let verifyingKeyDetails = self._setCfragCorrectnessKey(keyType: "verifying",
                                                               key: verifying)
        
        return (delegatingKeyDetails, receivingKeyDetails, verifyingKeyDetails)
    }
    
    func attachCfrag(cfrag: CapsuleFrag) {
        if cfrag.verifyCorrectness() {
            self._attachedCfrags!.append(cfrag)
        } else {
            precondition(false)
        }
    }
    
    func attachCfrag(cfrag: CapsuleFrag) {
        if cfrag.verifyCorrectness {
            self._attachedCfrags!.append(cfrag)
        } else {
            precondition(false)
        }
    }
    
    
}

func encrypt(alicePubkey: UmbralPublicKey,
             plaintext: [UInt8]) -> ([UInt8], Capsule) {
    let (key, capsule) = _encapsulate(alicePubkey: alicePubkey, keyLength: DEM_KEYSIZE)
    let capsuleBytes = bytes(capsule)
    let dem = UmbralDEM(symmKey: key)
    let ciphertext = dem.encrypt(plaintext, authenticatedData: capsuleBytes)
    return (ciphertext, capsule)
}

func _encapsulate(alicePubkey: UmbralPublicKey,
                  keyLength: Int = DEM_KEYSIZE) -> ([UInt8], Capsule) {
    let params = alicePubkey.params
    let g = params?.g
    
    let privR = BigInt.genRand(params.curve)
    let pubR = privR * g
    
    let privU = BigInt.genRand(params.curve)
    let pubU = privU * g
    
    let h = BigInt.hash(pubR, pubU, params: params)
    let s = privU + (privR * h)
    
    let sharedKey = (privR + privU) * alicePubkey.pointKey
    let key = kdf(sharedKey, keyLength)
    
    return (key, Capsule(pointE: pubR, pointV: pubU, bnSig: s, params: params))
}

func decrypt(ciphertext: [UInt8],
             capsule: Capsule,
             decryptingKey: UmbralPrivateKey,
             checkProof: Bool = true) -> [UInt8] {
    var encapsulatedKey: [UInt8]
    var capsuleBytes: [UInt8]
    if capsule._attachedCfrags {
        encapsulatedKey = _openCapsule(capsule,
                                       decryptingKey,
                                       checkProof: checkProof)
        capsuleBytes = capsule._originalToBytes()
    } else {
        encapsulatedKey = _openCapsule(decryptingKey,
                                       capsule)
        capsuleBytes = bytes(Capsule)
    }
    
    let dem = UmbralDEM(encapsulatedKey)
    let cleartext = dem.decrypt(ciphertext,
                                authenticatedData: capsuleBytes)
    
    return cleartext
}

func splitRekey(delegatingPrivkey: UmbralPrivateKey,
                signer: Signer,
                receivingPubkey: UmbralPublicKey,
                threshold: Int,
                N: Int) -> [KFag] {
    if threshold <= 0 || threshold > N {
        precondition(false)
    }
    
    if delegatingPrivkey.params != receivingPubkey.params {
        precondition(false)
    }
    
    let params = delegatingPrivkey.params
    
    let g = params?.g!
    
    let pubkeyApoint = delegatingPrivkey.getPubkey().pointKey
    let privkeyAbn = delegatingPrivkey.bnKey
    
    let pubkeyBpoint = receivingPubkey.pointKey
    
    let privNi = BigInt.genRand(params.curve)
    let ni = privNi * g
    let d = BigInt.hash(ni, pubkeyBpoint, pubkeyBpoint * privNi, params: params)
    
    var coeffs = [privkeyAbn * (~d)]
    for _ in 0..<threshold - 1 {
        coeffs += [BigInt.genRand(params.curve)
    }
    
    let u = params.u
    
    let privXcoord = BigInt.genRand(params.curve)
    let xcoord = privXcoord * g
    
    let dhXcoord = privXcoord * pubkeyBpoint
    
    //TODO: -
    var blake2b = hashes.Hash(hashes.BLAKE2b(64), backend: backend)
    blake2b.update(xcoord.toBytes())
    blake2b.update(pubkeyBpoint.toBytes())
    blake2b.update(dhXcoord.toBytes())
    let hashedDhtuple = blake2b.finalize()
    
    let bnSize = BigInt.expectedBytesLength(params.curve)
    
    var kfrags = []
    
    var id
    for _ in 0..<N {
        id = os.urandom(bnSize)
    }
    
    let shareX = CurveBN.hash(id, hashedDhtuple, params: params)
    
    let rk = polyEval(coeffs, shareX)
    
    let u1 = rk * u
    
    var kfragValidityMessage = [UInt8]
    for material in (id, pubkeyApoint, pubkeyBpoint, u1, ni, xcoord) {
        kfragValidityMessage = bytes().join(bytes(material))
    }
    let signature = signer(kfragValidityMessage)
    
    let kfrag = KFrag(id: id,
                      bnKey: rk,
                      pointNoninteractive: ni,
                      pointCommitment: u1,
                      pointXcoord: xcoord,
                      signature: signature)
    
    kfrags.append(kfrag)
    
    return kfrags
}

func reencrypt(kfrag: KFrag,
               capsule: Capsule,
               provideProof: Bool = true,
               metadata: [UInt8]? = nil) -> CapsuleFrag {
    if capsule == nil || !capsule.verify() {
        precondition(false)
    }
    
    if kfrag == nil || !kfrag.verifyForCapsule(capsule) {
        precondition(false)
    }
    
    let rk = kfrag._bnKey
    let e1 = rk * capsule._pointE
    let v1 = rk * capsule._pointV
    
    let cfrag = CapsuleFrag(pointE1: e1,
                            point_v1: v1,
                            kfragId: kfrag._id,
                            pointNoninteractive: kfrag._pointNoninteractive,
                            pointXcoord: kfrag._pointXcoord)
    
    if provideProof {
        proveCfragCorrectness(cfrag, kfrag, capsule, metadata)
    }
    
    return cfrag
}



