require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V2::Converter do
  it "renders areas" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :area: first_area, second_area

      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <area>first_area</area><area>second_area</area>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "deals with entities in areas" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :area: first_area & second_area

      == Section 1
      text
    INPUT
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE rfc SYSTEM "rfc2629.dtd">

      <rfc
                submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <area>first_area &amp; second_area</area>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
         <t>text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
