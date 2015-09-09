require 'taggata_test_helper'

module Taggata
  describe Scanner do
    let(:workdir) { ::Dir.mktmpdir }
    let(:scanner) { Scanner.new }
    let(:root) { Models::Directory.find_or_create(:name => workdir) }
    let(:file) { mock }

    before do
      scanner.expects(:report).at_least_once
    end

    after do
      FileUtils.rm_rf workdir
    end

    it 'process creates initial job' do
      root
      scanner.expects(:report_header)
      scanner.expects(:do_job).with(root.id, root.name)
      scanner.process(root)
    end

    it 'scans empty directory' do
      scanner.expects(:report_header)
      scanner.expects(:save_missing).never
      scanner.expects(:add_directory_jobs).never
      scanner.process(root)
    end

    it 'scans directory with files' do
      scanner.expects(:report_header)
      basenames = (1..5).map { |i| "file-#{i}" }
      basenames.each do |name|
        FileUtils.touch(::File.join(workdir, name))
      end
      scanner.expects(:add_directory_jobs).never
      scanner.process(root)
    end

    it 'scans subdirectories' do
      scanner.expects(:report_header)
      basenames = (1..5).map { |i| "file-#{i}" }
      subdir_path = ::File.join(workdir, 'subdir')
      FileUtils.mkdir_p(subdir_path)
      subdir = Models::Directory.find_or_create(:name => 'subdir',
                                                :parent_id => root.id)
      basenames.each do |name|
        FileUtils.touch(::File.join(subdir_path, name))
        Models::File.expects(:find_or_create).with(:name => name, :parent_id => subdir.id)
      end
      # scanner.expects(:add_directory_jobs).with([subdir_path], root.id)
      scanner.process(root)
    end
  end
end
