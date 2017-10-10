require "spec_helper"

xdescribe Asciidoctor::RFC::V2::Converter do
  it "renders an example" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      .Title
      ====
      Example
      ====
    INPUT
      Lipsum
    OUTPUT
  end
end