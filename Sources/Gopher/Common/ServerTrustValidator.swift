//
//  ServerTrustValidator.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation
import os

struct ServerTrustValidator
{
    enum ValidationResult
    {
        case allowConnection
        case blockConnection
    }

    private var pinnedPublicKeys: [SecKey] = []
    private let logger: Logger

    private enum ServerTrustError: Error
    {
        case couldNotEvaluateCertificate
        case invalidCertificate
        case couldNotExtractPublicKey
        case noCertificatesFound
    }

    init(logger: Logger? = nil)
    {
        if let logger = logger
        {
            self.logger = logger
        }
        else
        {
            self.logger = Logger(subsystem: "com.themacronaut.gopher.logger", category: "Trust Validator")
        }

        let allowedKeys = configureTrustValidator()

        pinnedPublicKeys = allowedKeys
    }

    public func validateServerTrust(serverTrust: SecTrust, hostName: String) -> ValidationResult
    {
        let trustChoice: ValidationResult

        if verifyPublicKey(serverTrust: serverTrust, hostName: hostName)
        {
            trustChoice = .allowConnection
        }
        else
        {
            trustChoice = .blockConnection
        }

        return trustChoice
    }
}

// MARK: - Helpers

extension ServerTrustValidator
{
    // 0
    private func configureTrustValidator() -> [SecKey]
    {
        var pubKeys: [SecKey] = []

        let bundle = Bundle.main
        let paths = bundle.paths(forResourcesOfType: "der", inDirectory: ".")

        for path in paths
        {
            do
            {
                let certificateData = try Data(contentsOf: URL(fileURLWithPath: path))

                if !certificateData.isEmpty
                {
                    let result = extractPublicKeyFromData(certificateData: certificateData)

                    switch result
                    {
                        case .success(let publicKey):
                            pubKeys.append(publicKey)
                        case .failure:
                            logger.debug("Could not extract public key from the certificate.")
                    }
                }
                else
                {
                    logger.debug("Could not read the certificate.")
                }
            }
            catch
            {
                logger.debug("Could not initialize data with contents of the URL \(path)")
            }
        }

        return pubKeys
    }

    // 1
    private func extractPublicKeyFromData(certificateData: Data) -> Result<SecKey, ServerTrustError>
    {
        let result: Result<SecKey, ServerTrustError>
        let cert = SecCertificateCreateWithData(nil, certificateData as CFData)

        if let extractedCert = cert
        {
            result = extractPublicKeyFromCertificate(certificate: extractedCert)
        }
        else
        {
            result = Result.failure(ServerTrustError.couldNotExtractPublicKey)
        }

        return result
    }

    // 2
    private func verifyPublicKey(serverTrust: SecTrust, hostName: String) -> Bool
    {
        var publicKeyVerified = false

        let isCertValid = validateCertificate(certificate: serverTrust,
                                              hostName: hostName)

        if isCertValid
        {
            let serverTrustPublicKey = extractPublicKeyFromServerTrust(serverTrust: serverTrust)

            if case .success(let publicKey) = serverTrustPublicKey
            {
                publicKeyVerified = findPublicKey(expectedKey: publicKey)
            }
            else
            {
                // Nothing to do, already initialized
                // to the default value.
            }

            let verifyLog = publicKeyVerified ? "👍 Matched" : "💩 Could not match"

            logger.debug("\(verifyLog) public key")
        }
        else
        {
            logger.debug("Invalid certificate was provided.")
        }

        return publicKeyVerified
    }

    // 3
    private func validateCertificate(certificate: SecTrust, hostName: String) -> Bool
    {
        var evaluateError: CFError?
        let isCertValid = SecTrustEvaluateWithError(certificate, &evaluateError)

        if isCertValid == false
        {
            let evaluationDetails = SecTrustCopyResult(certificate)

            logger.debug("Error: Validation failed for \(hostName): \(String(describing: evaluationDetails))")
        }
        else
        {
            // Nothing to do. Certificate is valid.
        }

        return isCertValid
    }

    // 4
    private func extractPublicKeyFromServerTrust(serverTrust: SecTrust) -> Result<SecKey, ServerTrustError>
    {
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        let result: Result<SecKey, ServerTrustError>

        if certificateCount > .zero
        {
            if let certChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
               let cert = certChain.first
            {
                result = extractPublicKeyFromCertificate(certificate: cert)
            }
            else
            {
                result = Result.failure(ServerTrustError.couldNotEvaluateCertificate)
            }
        }
        else
        {
            result = Result.failure(ServerTrustError.noCertificatesFound)
        }

        return result
    }

    // 5
    private func extractPublicKeyFromCertificate(certificate: SecCertificate) -> Result<SecKey, ServerTrustError>
    {
        var allowedCert: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        let certCreateStatus = SecTrustCreateWithCertificates(certificate, policy, &allowedCert)

        guard let certAllowed = allowedCert,
              certCreateStatus == errSecSuccess
        else
        {
            return Result.failure(ServerTrustError.couldNotEvaluateCertificate)
        }

        let result: Result<SecKey, ServerTrustError>
        var certEvaluateError: CFError?
        let certEvaluateResult = SecTrustEvaluateWithError(certAllowed, &certEvaluateError)

        if !certEvaluateResult,
           let publicKey = SecTrustCopyKey(certAllowed)
        {
            result = Result.success(publicKey)
        }
        else
        {
            result = Result.failure(ServerTrustError.couldNotEvaluateCertificate)
        }

        return result
    }

    // 6
    private func findPublicKey(expectedKey: SecKey) -> Bool
    {
        var foundPublicKey = false

        for pubkey in pinnedPublicKeys
        {
            foundPublicKey = (pubkey as AnyObject).isEqual(expectedKey)

            if foundPublicKey == true
            {
                break
            }
        }

        return foundPublicKey
    }
}
