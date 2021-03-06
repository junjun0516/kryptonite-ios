//
//  Properties.swift
//  Kryptonite
//
//  Created by Alex Grinman on 10/5/16.
//  Copyright © 2016 KryptCo, Inc. All rights reserved.
//

import Foundation

struct Properties {
    
    //MARK: Version
    static let currentVersion = Version(major: 2, minor: 1, patch: 0)
    
    struct Compatibility {
        static let rsaSha256Sha512Support = Version(major: 2, minor: 1, patch: 0)
    }
    
    static let appVersionURL = "https://s3.amazonaws.com/kr-versions/versions"
    
    static let updateCheckIntervalForeground = TimeSeconds.hour.multiplied(by: 6)
    static let updateCheckIntervalBackground = TimeSeconds.week.rawValue

    //MARK: AWS
    static let awsAccessKey = "AKIAJMZJ3X6MHMXRF7QQ"
    static let awsSecretKey = "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"

    struct AWSPlatformARN {
        let sandbox:String
        let production:String
    }
    
    static let awsPlatformARN = AWSPlatformARN(
        sandbox: "arn:aws:sns:us-east-1:911777333295:app/APNS_SANDBOX/kryptco-ios-dev",
        production: "arn:aws:sns:us-east-1:911777333295:app/APNS/kryptco-ios-prod")
    
    static let awsQueueURLBase = "https://sqs.us-east-1.amazonaws.com/911777333295/"
    

    //MARK: URLs

    static let contactUsEmail = "hello@krypt.co"
    static let openSourceURL = "https://krypt.co/app/open-source-libraries"
    static let privacyPolicyURL = "https://krypt.co/app/privacy"
    
    static let appStoreURL = "https://get.krypt.co"
    static let appURL = "https://krypt.co"

    //MARK: Analytics
    static var trackingID:String {
        if Platform.isDebug {
            return  "UA-86173430-1"
        }
        
        return "UA-86173430-2"
    }

    static let communicationActivityTimeout = 60.0
    static let requestTimeTolerance = 120.0

    init() {}
    
}
