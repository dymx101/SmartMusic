import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var showMainContent = false
    
    var body: some View {
        ZStack {
            Color("LaunchScreenBackground") // 使用主题色作为背景
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo动画
                Image("musiclogo") // 需要添加应用logo图片资源
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                
                // 应用名称动画
                Text(NSLocalizedString("app.name", comment: ""))
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                
                // 加载指示器
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .opacity(isAnimating ? 1 : 0)
                
                
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                isAnimating = true
            }
            
            // 2秒后切换到主内容
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showMainContent = true
                }
            }
        }
    }
} 
