//
//  LocalizeStrings.swift
//  Localize
//
//  Copyright © 2017 @andresilvagomez.
//

import Foundation

class LocalizeStrings: LocalizeCommonProtocol {

    fileprivate lazy var localizejson = LocalizeJson()
    
    /// Create default lang name
    override init() {
        super.init()
        fileName = "Strings"
    }

    /// Show all aviable languages with criteria name
    ///
    /// - returns: list with storaged languages code
    override var availableLanguages: [String] {
        var availableLanguages = bundle.localizations
        if let indexOfBase = availableLanguages.index(of: "Base") {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages
    }

    // MARK: Public methods

    /// Localize a string using your JSON File
    /// If the key is not found return the same key
    /// That prevent replace untagged values
    ///
    /// - returns: localized key or same text
    public override func localize(key: String, tableName: String? = nil) -> String {
        let tableName = tableName ?? fileName

        // First, try to find translation in currentLanguage.
        if let localized = localize(key: key, tableName: tableName, lang: currentLanguage) {
            return localized
        }

        // If current language contains a language/region divider, try general language without
        // a specific region.
        if currentLanguage.contains("-"),
            let lang = currentLanguage.split(separator: "-").first,
            let localized = localize(key: key, tableName: tableName, lang: String(lang)) {

            return localized
        }

        // Fall back to the defaultLange - "en" by default, but could have been changed.
        if let localized = localize(key: key, tableName: tableName, lang: defaultLanguage) {
            return localized
        }

        // If default language contains a language/region divider, try general language without
        // a specific region.
        if defaultLanguage.contains("-"),
            let lang = defaultLanguage.split(separator: "-").first,
            let localized = localize(key: key, tableName: tableName, lang: String(lang)) {

            return localized
        }

        if bundle.path(forResource: tableName, ofType: "strings") != nil {
            let localized = bundle.localizedString(forKey: key, value: nil, table: tableName)

            if localized != key {
                return localized
            }
        }
        
        // If any json file path is given
        if fileURL.path.localizedCaseInsensitiveCompare(Bundle.main.bundleURL.path) != .orderedSame,
            FileManager.default.fileExists(atPath: fileURL.path) {
            return localizejson.localize(key: key, tableName: tableName)
        }

        // If we can't find a translation anywhere, return the original key.
        return key
    }

    /// Internal helper method:
    /// Localize a key for the given table and language.
    ///
    /// - parameter key: The key for a string in the table identified by tableName.
    /// - parameter tableName: The receiver’s string table to search. If tableName is nil or is an
    ///   empty string, the method attempts to use the table in Localizable.strings.
    /// - parameter lang: The locale's folder name.
    /// - returns: A localized version of the string designated by key in table tableName or NIL,
    ///   if not found.
    private func localize(key: String, tableName: String, lang: String) -> String? {
        if let path = bundle.path(forResource: lang, ofType: "lproj"),
            let bundle = Bundle(path: path) {

            let localized = bundle.localizedString(forKey: key, value: nil, table: tableName)

            if localized != key {
                return localized
            }
        }

        return nil
    }
}
