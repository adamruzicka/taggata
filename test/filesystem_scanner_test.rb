require 'taggata_test_helper'

module Taggata
  describe FilesystemScanner do
    let(:workdir) { ::Dir.mktmpdir }
    let(:scanner) { FilesystemScanner.new }
    let(:root) { Directory.find_or_create(:name => workdir) }
    let(:default_tag) { mock }
    let(:file) { mock }

    after do
      FileUtils.rm_rf workdir
    end

    it 'scans empty folder' do
      root
      File.expects(:find_or_create).never
      Directory.expects(:find_or_create).never
      scanner.process(root)
    end

    it 'scans directory with files' do
      root
      Tag.expects(:find_or_create).returns(default_tag)
      file.expects(:add_tag).with(default_tag).times(5)
      5.times do |i|
        FileUtils.touch(::File.join(workdir, "file-#{i}"))
        File.expects(:find_or_create)
          .with(:name => "file-#{i}", :parent_id => root.id)
          .returns(file)
      end
      Directory.expects(:find_or_create).never
      scanner.process(root)
    end

    it 'scans subdirectories' do
      root
      FileUtils.mkdir_p(::File.join(workdir, 'subdir'))
      Tag.expects(:find_or_create).returns(default_tag)
      file.expects(:add_tag).with(default_tag).times(5)
      subdir = Directory.find_or_create(:name => 'subdir',
                                        :parent_id => root.id)
      5.times do |i|
        FileUtils.touch(::File.join(workdir, 'subdir', "file-#{i}"))
        File.expects(:find_or_create)
          .with(:name => "file-#{i}", :parent_id => subdir.id)
          .returns(file)
      end
      Directory.expects(:find_or_create)
        .with(:name => 'subdir', :parent_id => root.id)
        .returns(subdir)
      scanner.expects(:report)
      scanner.process(root)
    end
  end
end
