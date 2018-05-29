//
//  ViewRow.swift
//  CustomViewRow
//
//  Created by Mark Alldritt on 2017-09-13.
//  Copyright © 2017 Late Night Software Ltd. All rights reserved.
//
import UIKit

public class ViewCell<ViewType : UIView> : Cell<String>, CellType {
    
    public var view : ViewType?
    
    public var viewRightMargin = CGFloat(0)
    public var viewLeftMargin = CGFloat(0)
    public var viewTopMargin = CGFloat(0)
    public var viewBottomMargin = CGFloat(0)
    
    public var titleLeftMargin = CGFloat(0)
    public var titleRightMargin = CGFloat(0)
    public var titleTopMargin = CGFloat(0)
    public var titleBottomMargin = CGFloat(0)
    
    public var titleLabel : UILabel?
    
    private var notificationObserver : NSObjectProtocol?
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let notificationObserver = notificationObserver {
            NotificationCenter.default.removeObserver(notificationObserver)
        }
    }
    
    open override func setup() {
        super.setup()
        
        titleLabel = UILabel(frame: CGRect.zero)
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        contentView.addSubview(titleLabel!)
        
        //  Provide a default row height calculation based on the height of the assigned view.
        height = {
            if self.titleLabel!.text == nil || self.titleLabel!.text == "" {
                return ceil(self.view?.frame.height ?? 0 + self.viewTopMargin + self.viewBottomMargin)
            }
            else {
                let titleHeight = ceil(self.titleLabel!.sizeThatFits(CGSize(width: self.contentView.frame.width - self.titleLeftMargin - self.titleRightMargin, height: 9999.0)).height)
                
                return ceil(titleHeight + self.titleTopMargin + self.titleBottomMargin + (self.view?.frame.height ?? 0.0) + self.viewTopMargin + self.viewBottomMargin)
            }
        }
        
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIContentSizeCategoryDidChange,
                                                                      object: nil,
                                                                      queue: nil,
                                                                      using: { [weak self] (note) in
                                                                        self?.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
                                                                        self?.setNeedsLayout()
        })
        
        selectionStyle = .none
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        //  This could be done with autolayout, but this seems simpler...
        let contentFrame = contentView.frame
        
        if titleLabel!.text == nil || titleLabel!.text == "" {
            titleLabel!.frame = CGRect.zero
            view?.frame = CGRect(x: viewLeftMargin,
                                 y: viewTopMargin,
                                 width: contentFrame.width - viewLeftMargin - viewRightMargin,
                                 height: contentFrame.height - viewTopMargin - viewBottomMargin)
        }
        else {
            let titleHeight = ceil(titleLabel!.sizeThatFits(CGSize(width: contentFrame.width - titleLeftMargin - titleRightMargin, height: 9999.0)).height)
            let titleFrame = CGRect(x: titleLeftMargin,
                                    y: titleTopMargin,
                                    width: contentFrame.width - titleLeftMargin - titleRightMargin,
                                    height: titleHeight)
            let viewFrame = CGRect(x: viewLeftMargin,
                                   y: titleFrame.maxY + titleBottomMargin + viewTopMargin,
                                   width: contentFrame.width - viewLeftMargin - viewRightMargin,
                                   height: ceil(contentFrame.height - titleFrame.maxY - titleBottomMargin - viewTopMargin - viewBottomMargin))
            
            titleLabel!.frame = titleFrame
            view?.frame = viewFrame
        }
    }
    
}

// MARK: ViewRow
open class _ViewRow<ViewType : UIView>: Row<ViewCell<ViewType> > {
    
    open var presentationMode: PresentationMode<UIViewController>?

    override open func updateCell() {
        //  NOTE: super.updateCell() deliberatly not called.
        
        //  Deal with the case where the caller did not add their custom view to the containerView in a
        //  backwards compatible manner.
        if let view = cell.view,
            view.superview != cell.contentView {
            view.removeFromSuperview()
            cell.contentView.addSubview(view)
        }
        cell.titleLabel?.text = title
    }
    
    open override func didSelect() {
        if let presentationMode = presentationMode {
            if let controller = presentationMode.makeController() {
                presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
            } else {
                presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
            }
        }
    }
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public final class ViewRow<ViewType : UIView>: _ViewRow<ViewType>, RowType {
    
    public var view: ViewType? { // provide a convience accessor for the view
        return cell.view
    }
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
}
