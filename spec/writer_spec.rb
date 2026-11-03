# frozen_string_literal: true

require "tmpdir"

RSpec.describe GraphqlTagRbs::Writer do
  around { |example| Dir.mktmpdir { |dir| @dir = dir; example.run } }

  def write(files) = described_class.new(@dir).write(files)

  let(:generated) { "#{GraphqlTagRbs::Generator::HEADER} from app/a.rb. Do not edit.\n" }

  it "writes files into nested directories" do
    result = write("app/a.rbs" => generated)

    expect(File.read(File.join(@dir, "app/a.rbs"))).to eq(generated)
    expect(result.written).to eq([File.join(@dir, "app/a.rbs")])
  end

  it "removes generated files that are no longer produced, but keeps other files" do
    write("app/a.rbs" => generated, "app/old.rbs" => generated)
    File.write(File.join(@dir, "app/handwritten.rbs"), "module Mine\nend\n")

    result = write("app/a.rbs" => generated)

    expect(result.deleted).to eq([File.join(@dir, "app/old.rbs")])
    expect(Dir.children(File.join(@dir, "app")).sort).to eq(["a.rbs", "handwritten.rbs"])
  end

  it "does not rewrite unchanged files" do
    write("app/a.rbs" => generated)
    path = File.join(@dir, "app/a.rbs")
    File.utime(Time.at(0), Time.at(0), path)

    write("app/a.rbs" => generated)

    expect(File.mtime(path)).to eq(Time.at(0))
  end
end
