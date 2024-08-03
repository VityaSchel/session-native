import Foundation
import SwiftUI

struct AccordionStyle: DisclosureGroupStyle {
  @State private var viewHeight: CGFloat = 0
  @State private var viewWidth: CGFloat = 0
  
  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Button {
        withAnimation {
          configuration.isExpanded.toggle()
        }
      } label: {
        Button {
          withAnimation {
            configuration.isExpanded.toggle()
          }
        } label: {
          HStack {
            Image(systemName: "chevron.right")
              .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
            configuration.label
            Spacer()
          }
          .padding(.vertical, 6)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
      }
      .buttonStyle(.plain)
      
      ZStack {
        configuration.content
          .animation(.none)
          .frame(width: viewWidth, height: .infinity)
          .frame(minWidth: 0)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(height: configuration.isExpanded ? nil : 0, alignment: .top)
      .clipped()
    }
    .frame(maxWidth: .infinity)
    .background {
      GeometryReader { geometry in
        Color.clear
          .preference(key: ViewSizeKey.self, value: geometry.size)
      }
    }
    .onPreferenceChange(ViewSizeKey.self) { size in
      viewWidth = size.width
    }
  }
}

struct ViewSizeKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

struct AnimatedClipShape: Shape {
  var expand: Bool
  var maxHeight: CGFloat
  
  var animatableData: CGFloat {
    get { expand ? maxHeight : 0 }
    set { }
  }
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let height = expand ? maxHeight : 0
    path.addRect(CGRect(x: 0, y: 0, width: rect.width, height: height))
    return path
  }
}

#Preview {
  ScrollView {
    VStack(alignment: .leading) {
      DisclosureGroup("Need help?") {
        VStack(alignment: .leading) {
          Image(systemName: "star")
          Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam sed mauris sit amet ex finibus suscipit. Nullam dapibus pulvinar eros, eget fringilla enim finibus ac. Nunc tempor sem in vehicula placerat. Nam vitae fermentum nisl. Proin dictum ligula vel interdum hendrerit. Curabitur maximus sollicitudin vehicula. Maecenas vestibulum vehicula viverra. Mauris vel dolor lorem. Nullam felis nulla, cursus sit amet nunc nec, venenatis mollis risus. Integer ut semper purus, a ullamcorper sem. Proin mattis facilisis est at molestie. Morbi lobortis hendrerit sapien sed fringilla. In volutpat nec libero ut consequat. Fusce placerat lectus odio, ac facilisis dolor egestas ac. Vestibulum porta elit et porttitor tincidunt. Ut imperdiet consectetur nunc sit amet scelerisque. ")
        }
      }
      .disclosureGroupStyle(AccordionStyle())
      Divider()
      DisclosureGroup("Help section with FAQ") {
        VStack(alignment: .leading) {
          Image(systemName: "star")
          Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam sed mauris sit amet ex finibus suscipit. Nullam dapibus pulvinar eros, eget fringilla enim finibus ac. Nunc tempor sem in vehicula placerat. Nam vitae fermentum nisl. Proin dictum ligula vel interdum hendrerit. Curabitur maximus sollicitudin vehicula. Maecenas vestibulum vehicula viverra. Mauris vel dolor lorem. Nullam felis nulla, cursus sit amet nunc nec, venenatis mollis risus. Integer ut semper purus, a ullamcorper sem. Proin mattis facilisis est at molestie. Morbi lobortis hendrerit sapien sed fringilla. In volutpat nec libero ut consequat. Fusce placerat lectus odio, ac facilisis dolor egestas ac. Vestibulum porta elit et porttitor tincidunt. Ut imperdiet consectetur nunc sit amet scelerisque. ")
        }
      }
      .disclosureGroupStyle(AccordionStyle())
      Divider()
      DisclosureGroup("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam sed mauris sit amet") {
        VStack(alignment: .leading) {
          Image(systemName: "star")
          Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam sed mauris sit amet ex finibus suscipit. Nullam dapibus pulvinar eros, eget fringilla enim finibus ac. Nunc tempor sem in vehicula placerat. Nam vitae fermentum nisl. Proin dictum ligula vel interdum hendrerit. Curabitur maximus sollicitudin vehicula. Maecenas vestibulum vehicula viverra. Mauris vel dolor lorem. Nullam felis nulla, cursus sit amet nunc nec, venenatis mollis risus. Integer ut semper purus, a ullamcorper sem. Proin mattis facilisis est at molestie. Morbi lobortis hendrerit sapien sed fringilla. In volutpat nec libero ut consequat. Fusce placerat lectus odio, ac facilisis dolor egestas ac. Vestibulum porta elit et porttitor tincidunt. Ut imperdiet consectetur nunc sit amet scelerisque. ")
        }
      }
      .disclosureGroupStyle(AccordionStyle())
      
      Spacer()
    }
    .padding()
  }
  .frame(width: 400, height: 400)
}
