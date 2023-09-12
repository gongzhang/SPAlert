//
//  SPAlertModifier.swift
//
//
//  Created by Gong Zhang on 2023/9/12.
//

import SwiftUI

public struct SPAlertConfiguration {
    public var title: String
    public var message: String? = nil
    public var icon: SPAlertIconPreset = .done
    public var layout: SPAlertLayout? = nil
    public var duration: TimeInterval = 2.0
    public var haptic: SPAlertHaptic = .none
    public var dismissOnTap: Bool = true
}

@available(iOS 13.0, *)
struct SPAlertPlaceholderView: UIViewRepresentable {
    
    @Binding var isPresented: Bool
    var configuration: SPAlertConfiguration
    
    func makeUIView(context: Context) -> UnderlyingView {
        UnderlyingView(isPresented: $isPresented, configuration: configuration)
    }
    
    func updateUIView(_ view: UnderlyingView, context: Context) {
        view.configuration = configuration
        
        if isPresented && view.presentedAlertView == nil {
            view.play()
            
        } else if !isPresented && view.presentedAlertView != nil {
            view.stop()
        }
    }
    
    static func dismantleUIView(_ view: UnderlyingView, coordinator: ()) {
        if let alert = view.presentedAlertView {
            alert.dismiss()
        }
    }
    
    class UnderlyingView: UIView {
        
        var isPresented: Binding<Bool>
        var configuration: SPAlertConfiguration
        
        weak var presentedAlertView: SPAlertView? = nil
        
        init(isPresented: Binding<Bool>, configuration: SPAlertConfiguration) {
            self.isPresented = isPresented
            self.configuration = configuration
            super.init(frame: .zero)
            backgroundColor = .clear
            isUserInteractionEnabled = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func play() {
            let alert = SPAlertView(title: configuration.title, message: configuration.message, preset: configuration.icon)
            presentedAlertView = alert
            
            alert.layout = configuration.layout ?? SPAlertLayout(for: configuration.icon)
            alert.dismissByTap = configuration.dismissOnTap
            alert.duration = configuration.duration
            alert.presentWindow = self.window
            alert.present(haptic: configuration.haptic) { [weak self] in
                self?.stop()
            }
        }
        
        func stop() {
            if let alert = presentedAlertView {
                alert.dismiss()
            }
            presentedAlertView = nil
            isPresented.wrappedValue = false
        }
    }
    
}

@available(iOS 13.0, *)
extension View {
    
    public func spAlert(isPresented: Binding<Bool>,
                        title: String,
                        message: String? = nil,
                        icon: SPAlertIconPreset = .done,
                        haptic: SPAlertHaptic = .none,
                        customize: (inout SPAlertConfiguration) -> () = { _ in }) -> some View {
        var configuration = SPAlertConfiguration(title: title,
                                                 message: message,
                                                 icon: icon,
                                                 haptic: haptic)
        customize(&configuration)
        
        return self.background(
            SPAlertPlaceholderView(isPresented: isPresented, configuration: configuration)
        )
    }
    
}

@available(iOS 13.0, tvOS 13.0, *)
struct SPAlertModifier_Previews: PreviewProvider {
    struct Preview: View {
        @State private var isPresenting = false
        
        var body: some View {
            VStack {
                Spacer()
                Toggle("🔔", isOn: $isPresenting)
                    .fixedSize()
            }
            .spAlert(isPresented: $isPresenting,
                     title: "Alert",
                     message: "Message",
                     icon: .heart)
        }
        
    }
    
    static var previews: some View {
        Preview()
    }
}
