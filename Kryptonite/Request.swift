//
//  Request.swift
//  Kryptonite
//
//  Created by Alex Grinman on 9/2/16.
//  Copyright © 2016 KryptCo, Inc. All rights reserved.
//

import Foundation
import JSON

struct Request:Jsonable {
    
    var id:String
    var unixSeconds:Int
    var sendACK:Bool
    var version:Version
    var sign:SignRequest?
    var me:MeRequest?
    var unpair:UnpairRequest?

    init(id: String, unixSeconds: Int, sendACK: Bool, version: Version, sign: SignRequest? = nil, me: MeRequest? = nil, unpair: UnpairRequest? = nil) {
        self.id = id
        self.unixSeconds = unixSeconds
        self.sendACK = sendACK
        self.version = version
        self.sign = sign
        self.me = me
        self.unpair = unpair
        
    }
    
    init(json: Object) throws {
        self.id = try json ~> "request_id"
        self.unixSeconds = try json ~> "unix_seconds"
        self.sendACK = (try? json ~> "a") ?? false
        self.version = try Version(string: json ~> "v")

        if let json:Object = try? json ~> "sign_request" {
            self.sign = try SignRequest(json: json)
        }
        
        if let json:Object = try? json ~> "me_request" {
            self.me = try MeRequest(json: json)
        }

        if let json:Object = try? json ~> "unpair_request" {
            self.unpair = try UnpairRequest(json: json)
        }
    }
    
    var object:Object {
        var json:[String:Any] = [:]
        json["request_id"] = id
        json["unix_seconds"] = unixSeconds
        json["a"] = sendACK
        json["v"] = version.string

        if let s = sign {
            json["sign_request"] = s.object
        }
        
        if let m = me {
            json["me_request"] = m.object
        }

        if let u = unpair {
            json["unpair_request"] = u.object
        }

        return json
    }

    func isNoOp() -> Bool {
        return sign == nil && me == nil && unpair == nil
    }
}

//MARK: Requests

// Sign

struct HostAuthVerificationFailed:Error{}

struct SignRequest:Jsonable {
    var data:SSHMessage //SSH_MSG_USERAUTH_REQUEST
    var fingerprint:String
    var verifiedHostAuth:VerifiedHostAuth?
    
    var session:Data
    var user:String
    var digestType:DigestType
    
    
    var isUnknownHost:Bool {
        return verifiedHostAuth?.hostName == nil
    }

    init(data: Data, fingerprint: String, hostAuth: HostAuth? = nil) throws {
        self.data = SSHMessage(data)
        self.fingerprint = fingerprint

        (session, user, digestType) = try SignRequest.parse(requestData: data)

        // TODO: Phase out "unknown host" asap
        // currently requests made while agent forwarding (ssh -A) aren't able to pass 
        // host_auth data to kr.
        if let potentialHostAuth = hostAuth {
            self.verifiedHostAuth = try? VerifiedHostAuth(session: session, hostAuth: potentialHostAuth)
        }
    }

    init(json: Object) throws {
        try self.init(data: ((json ~> "data") as String).fromBase64(),
                      fingerprint: json ~> "public_key_fingerprint",
                      hostAuth: try? HostAuth(json: json ~> "host_auth"))
    }
    
    /**
     Parse request data to get session, user, and digest algorithm type
     - throws: InvalidRequestData if data doesn't parse correctly.
     
     Parses according to the SSH packet protocol: https://tools.ietf.org/html/rfc4252#section-7
     
     Packet Format (SSH_MSG_USERAUTH_REQUEST):
         string    session identifier
         byte      SSH_MSG_USERAUTH_REQUEST
         string    user name
         string    service name
         string    "publickey"
         boolean   TRUE
         string    public key algorithm name
         
         /// Note: krd removes this to save space
         string    public key to be used for authentication
     */
    static func parse(requestData:SSHMessage) throws -> (session:Data, user:String, digestType:DigestType) {
        var data = Data(requestData)
        // session
        let session = try data.popData()
        
        // type
        let _ = try data.popByte()
        
        // user
        let user = try data.popString()
        
        // service, method, sign
        let _ = try data.popString()
        let _ = try data.popString()
        let _ = try data.popBool()

        let algo = try data.popString()
        
        let digestType = try DigestType(algorithmName: algo)
        
        return (session, user, digestType)
    }
    
    var object: Object {
        var json:[String:Any] = ["data": data.toBase64(),
                                 "public_key_fingerprint": fingerprint]
        
        if let auth = verifiedHostAuth {
            json["host_auth"] = auth.object
        }
        
        return json
    }
    
    var display:String {
        let host = verifiedHostAuth?.hostName ?? "unknown host"

        return "\(user) @ \(host)"
    }
}


// Me
struct MeRequest:Jsonable {
    init(json: Object) throws {}
    var object: Object {return [:]}
}

// Unpair
struct UnpairRequest:Jsonable {
    init(json: Object) throws {}
    var object: Object {return [:]}
}





