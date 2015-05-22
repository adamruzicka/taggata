require 'taggata_test_helper'

module Taggata
  describe FilesystemScanner do
    let(:workdir) { ::Dir.mktmpdir }
    let(:scanner) { FilesystemScanner.new }
    let(:root) { Directory.find_or_create(:name => workdir) }
    let(:file) { mock }

    before do
      scanner.expects(:report)
    end

    after do
      FileUtils.rm_rf workdir
    end

    it 'process creates initial job' do
      root
      scanner.expects(:do_job).with(root.id, root.name)
      scanner.process(root)
    end

    it 'scans empty directory' do
      scanner.expects(:save_missing).never
      scanner.expects(:add_directory_jobs).never
      scanner.process(root)
    end

    it 'scans directory with files' do
      basenames = (1..5).map { |i| "file-#{i}" }
      basenames.each do |name|
        FileUtils.touch(::File.join(workdir, name))
      end
      scanner.expects(:save_missing).with(basenames, root.id, ::Taggata::File)
      scanner.expects(:add_directory_jobs).never
      scanner.process(root)
    end

    it 'scans subdirectories' do
      basenames = (1..5).map { |i| "file-#{i}" }
      subdir_path = ::File.join(workdir, 'subdir')
      FileUtils.mkdir_p(subdir_path)
      Directory.find_or_create(:name => 'subdir',
                               :parent_id => root.id)
      basenames.each do |name|
        FileUtils.touch(::File.join(subdir_path, name))
      end
      scanner.expects(:add_directory_jobs).with([subdir_path], root.id)
      scanner.process(root)
    end
  end
end
