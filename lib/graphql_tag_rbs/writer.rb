# frozen_string_literal: true

require "fileutils"

module GraphqlTagRbs
  # Writes generated files into the output directory and removes generated
  # files that are no longer produced, such as those of a deleted source file.
  # Files without the generated header are never touched.
  class Writer
    Result = Struct.new(:written, :deleted, keyword_init: true)

    def initialize(output_dir)
      @output_dir = output_dir
    end

    def write(files)
      written = files.map do |relative_path, content|
        path = File.join(@output_dir, relative_path)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, content) unless File.exist?(path) && File.read(path) == content
        path
      end

      deleted = (Dir.glob(File.join(@output_dir, "**/*.rbs")) - written).select do |path|
        next false unless File.foreach(path).first.to_s.start_with?(Generator::HEADER)

        File.delete(path)
        true
      end

      Result.new(written: written, deleted: deleted)
    end
  end
end
