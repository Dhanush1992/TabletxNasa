//
//  YearRangePickerView.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/9/24.
//

import UIKit

@MainActor
protocol YearRangePickerViewDelegate: AnyObject {
    func didSelectYearRange(startYear: Int, endYear: Int)
}

class YearRangePickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let startYearPicker = UIPickerView()
    private let endYearPicker = UIPickerView()
    private let years = Array(1920...Calendar.current.component(.year, from: Date()))
    
    weak var delegate: YearRangePickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPickers()
    }
    
    private func setupPickers() {
        startYearPicker.delegate = self
        startYearPicker.dataSource = self
        startYearPicker.tag = 1
        endYearPicker.delegate = self
        endYearPicker.dataSource = self
        endYearPicker.tag = 2
        
        let stackView = UIStackView(arrangedSubviews: [startYearPicker, endYearPicker])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setInitialYears(startYear: Int, endYear: Int) {
        if let startYearIndex = years.firstIndex(of: startYear) {
            startYearPicker.selectRow(startYearIndex, inComponent: 0, animated: false)
        }
        
        if let endYearIndex = years.firstIndex(of: endYear) {
            endYearPicker.selectRow(endYearIndex, inComponent: 0, animated: false)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(years[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let startYear = years[startYearPicker.selectedRow(inComponent: 0)]
        let endYear = years[endYearPicker.selectedRow(inComponent: 0)]
        
        if startYear > endYear {
            // Ensure the start year is less than or equal to the end year
            if pickerView.tag == 1 {
                endYearPicker.selectRow(row, inComponent: 0, animated: true)
            } else {
                startYearPicker.selectRow(row, inComponent: 0, animated: true)
            }
        }
        
        delegate?.didSelectYearRange(startYear: startYear, endYear: endYear)
    }
}
