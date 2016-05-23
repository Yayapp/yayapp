//
//  CategoryPickerViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 19.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

protocol CategoryPickerDelegate : NSObjectProtocol {
    func madeCategoryChoice(categories: [Category])
}

final class CategoryPickerViewController: UIViewController {

    @IBOutlet private weak var categoriesCollection: TTGTextTagCollectionView!

    private var datasource: [Category]! = []

    var selectedCategoriesData:[Category]! = []
    var categoryDelegate: CategoryPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        tagCollectionViewSetupUI()
        loadData()
    }
}

extension CategoryPickerViewController {
    //MARK:- Action Buttons
    @IBAction func doneAction(sender: AnyObject) {
        categoryDelegate?.madeCategoryChoice(selectedCategoriesData)
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CategoryPickerViewController: TTGTextTagCollectionViewDelegate {
    //MARK:- TTGTextTagCollectionViewDelegate 
    func textTagCollectionView(textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, atIndex index: UInt, selected: Bool) {
        let category = datasource[Int(index)]
        if (selected){
            selectedCategoriesData.append(category)
        } else {
            selectedCategoriesData = selectedCategoriesData.filter({$0.objectId != category.objectId})
        }
    }
}

private extension CategoryPickerViewController {
    //MARK:- Api Data Fetchers
    func loadData() {
        SVProgressHUD.show()
        ParseHelper.getUserCategoriesForEvent({ categoriesList, error in
            SVProgressHUD.dismiss()
            if(error == nil) {
                self.datasource = categoriesList?.filter({ category -> Bool in
                    category.name != ""
                })

                for (index, category) in (self.datasource.enumerate()) {
                    self.categoriesCollection.addTag(category.name)
                    self.categoriesCollection.setTagAtIndex(UInt(index), selected: self.selectedCategoriesData.contains(category))
                }

            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }
}

private extension CategoryPickerViewController {
    //MARK:- UI Setup
    func tagCollectionViewSetupUI() {
        categoriesCollection.delegate = self
        categoriesCollection.tagTextColor = .blackColor()
        categoriesCollection.tagSelectedTextColor = .whiteColor()
        categoriesCollection.tagSelectedBackgroundColor = Color.PrimaryActiveColor
        categoriesCollection.tagTextFont = UIFont.boldSystemFontOfSize(15)
        categoriesCollection.tagCornerRadius = 10
        categoriesCollection.tagSelectedCornerRadius = 10
        categoriesCollection.tagBorderColor = .blackColor()
        categoriesCollection.tagSelectedBorderWidth = 0
        categoriesCollection.horizontalSpacing = 12
        categoriesCollection.verticalSpacing = 12
    }
}
