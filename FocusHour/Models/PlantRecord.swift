//
//  PlantRecord.swift
//  FocusHour
//
//  Created by Midrash Elucidator on 2019/2/15.
//  Copyright © 2019 Midrash Elucidator. All rights reserved.
//

import UIKit
import os.log

//MARK: Types
struct PlantRecordProperty {
    static let imgName = "imgName"
    static let minute = "minute"
    static let year = "year"
    static let month = "month"
    static let day = "day"
    static let tag = "tag"
}

class PlantRecord: NSObject, NSCoding {
    
    //MARK: Properties
    var imgName: String
    var minute: Int
    var year: Int
    var month: Int
    var day: Int
    var tag: String
    
    //MARK: Archiving Paths
    static let ArchiveURL = SystemConstant.DocumentsDirectory.appendingPathComponent("PlantRecords")
    static let RecordFile = "Records"
    static let TimeFile = "TotalTime"
    
    //MARK: Initialization
    init?(imgName: String, minute: Int, year: Int, month: Int, day: Int, tag: String) {
        guard !imgName.isEmpty else { return nil }
        guard minute >= 0 else { return nil }
        guard year > 0 else { return nil }
        guard (month > 0) && (month <= 12) else { return nil }
        guard (day > 0) && (day <= 31) else { return nil }
        guard !tag.isEmpty else { return nil }
        
        self.imgName = imgName
        self.minute = minute
        self.year = year
        self.month = month
        self.day = day
        self.tag = tag
    }
    
    init?(imgName: String, minute: Int, tag: String) {
        guard !imgName.isEmpty else { return nil }
        guard minute >= 0 else { return nil }
        
        self.imgName = imgName
        self.minute = minute
        self.year = TimeTool.getCurrentYear()
        self.month = TimeTool.getCurrentMonth()
        self.day = TimeTool.getCurrentDay()
        self.tag = tag
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(imgName, forKey: PlantRecordProperty.imgName)
        aCoder.encode(minute, forKey: PlantRecordProperty.minute)
        aCoder.encode(year, forKey: PlantRecordProperty.year)
        aCoder.encode(month, forKey: PlantRecordProperty.month)
        aCoder.encode(day, forKey: PlantRecordProperty.day)
        aCoder.encode(tag, forKey: PlantRecordProperty.tag)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let imgName = aDecoder.decodeObject(forKey: PlantRecordProperty.imgName) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let tag = aDecoder.decodeObject(forKey: PlantRecordProperty.tag) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        let minute = aDecoder.decodeInteger(forKey: PlantRecordProperty.minute)
        let year = aDecoder.decodeInteger(forKey: PlantRecordProperty.year)
        let month = aDecoder.decodeInteger(forKey: PlantRecordProperty.month)
        let day = aDecoder.decodeInteger(forKey: PlantRecordProperty.day)
        self.init(imgName: imgName, minute: minute, year: year, month: month, day: day, tag: tag)
    }
}

extension PlantRecord {
    
    func save() {
        saveRecords()
        updateTotalTime()
    }
    
    private func saveRecords() {
        do {
            var records = PlantRecord.loadRecords(year: year, month: month)
            records.append(self)
            let fileURL = PlantRecord.getDirectory(year: year, month: month).appendingPathComponent(PlantRecord.RecordFile)
            let data = try NSKeyedArchiver.archivedData(withRootObject: records, requiringSecureCoding: false)
            try data.write(to: fileURL)
        } catch {
            return
        }
    }
    
    private func updateTotalTime() {
        do {
            let totalTime = PlantRecord.loadTotalTime(year: year, month: month) + minute
            let fileURL = PlantRecord.getDirectory(year: year, month: month).appendingPathComponent(PlantRecord.TimeFile)
            let data = try NSKeyedArchiver.archivedData(withRootObject: totalTime, requiringSecureCoding: false)
            try data.write(to: fileURL)
        } catch {
            return
        }
    }
    
    static func loadRecords(year: Int, month: Int) -> [PlantRecord] {
        do {
            let fileURL = PlantRecord.getDirectory(year: year, month: month).appendingPathComponent(PlantRecord.RecordFile)
            let fileData = try Data(contentsOf: fileURL)
            let result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData)
            return result as! [PlantRecord]
        } catch {
            return []
        }
    }
    
    static func loadTotalTime(year: Int, month: Int) -> Int {
        do {
            let fileURL = PlantRecord.getDirectory(year: year, month: month).appendingPathComponent(PlantRecord.TimeFile)
            let fileData = try Data(contentsOf: fileURL)
            let result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData)
            return result as! Int
        } catch {
            return 0
        }
    }
    
    static func getDirectory(year: Int, month: Int) -> URL {
        let url = PlantRecord.ArchiveURL.appendingPathComponent("\(year)").appendingPathComponent("\(month)")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            try! fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
    
    static func getRecordYears() -> [Int] {
        do {
            let fileManager = FileManager.default
            let years = try fileManager.contentsOfDirectory(atPath: PlantRecord.ArchiveURL.path)
            var result = years.map { year -> Int in return Int(year) ?? TimeTool.getCurrentYear()}
            result.sort(by: {(x, y) -> Bool in return x >= y})
            return result.count > 0 ? result : [TimeTool.getCurrentYear()]
        } catch {
            return [TimeTool.getCurrentYear()]
        }
    }
    
    static func generateRandomRecords() {
        let circleView = CircleView()
        for year in 2017...2018 {
            for month in 1...12 {
                for _ in 0..<10 {
                    let day = Int.random(in: 1...28)
                    let minute = Int.random(in: 10...120)
                    let imgName = circleView.getRecordImageNameBy(focusMinutes: minute)
                    let plantRecord = PlantRecord(imgName: imgName, minute: minute, year: year, month: month, day: day, tag: LocalizationKey.Focus.translate())
                    plantRecord?.save()
                }
            }
        }
        
        let year = TimeTool.getCurrentYear()
        let currentMonth = TimeTool.getCurrentMonth()
        for month in 1...currentMonth {
            for _ in 0..<10 {
                let day = Int.random(in: 1...28)
                let minute = Int.random(in: 10...120)
                let imgName = circleView.getRecordImageNameBy(focusMinutes: minute)
                let plantRecord = PlantRecord(imgName: imgName, minute: minute, year: year, month: month, day: day, tag: LocalizationKey.Focus.translate())
                plantRecord?.save()
            }
        }
    }
}
