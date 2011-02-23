require File.expand_path('../../../../../../test_helper', __FILE__)
begin
  require 'mocha'

  class MercurialAdapterTest < ActiveSupport::TestCase

    TEMPLATES_DIR = Redmine::Scm::Adapters::MercurialAdapter::TEMPLATES_DIR
    TEMPLATE_NAME = Redmine::Scm::Adapters::MercurialAdapter::TEMPLATE_NAME
    TEMPLATE_EXTENSION = Redmine::Scm::Adapters::MercurialAdapter::TEMPLATE_EXTENSION

    REPOSITORY_PATH = RAILS_ROOT.gsub(%r{config\/\.\.}, '') + '/tmp/test/mercurial_repository'

    if File.directory?(REPOSITORY_PATH)
      def setup
        @adapter = Redmine::Scm::Adapters::MercurialAdapter.new(REPOSITORY_PATH)
      end

      def test_hgversion
        to_test = { "Mercurial Distributed SCM (version 0.9.5)\n"  => [0,9,5],
                    "Mercurial Distributed SCM (1.0)\n"            => [1,0],
                    "Mercurial Distributed SCM (1e4ddc9ac9f7+20080325)\n" => nil,
                    "Mercurial Distributed SCM (1.0.1+20080525)\n" => [1,0,1],
                    "Mercurial Distributed SCM (1916e629a29d)\n"   => nil,
                    "Mercurial SCM Distribuito (versione 0.9.5)\n" => [0,9,5],
                    "(1.6)\n(1.7)\n(1.8)"                          => [1,6],
                    "(1.7.1)\r\n(1.8.1)\r\n(1.9.1)"                => [1,7,1]}

        to_test.each do |s, v|
          test_hgversion_for(s, v)
        end
      end

      def test_template_path
        to_test = { [0,9,5]  => "0.9.5",
                    [1,0]    => "1.0",
                    []       => "1.0",
                    [1,0,1]  => "1.0",
                    [1,7]    => "1.0",
                    [1,7,1]  => "1.0" }
        to_test.each do |v, template|
          test_template_path_for(v, template)
        end
      end

      def test_diff
        if @adapter.class.client_version_above?([1, 2])
          assert_nil @adapter.diff(nil, '100000')
        end
        assert_nil @adapter.diff(nil, '100000', '200000')
        [2, '400bb8672109', '400', 400].each do |r1|
          diff1 = @adapter.diff(nil, r1)
          if @adapter.class.client_version_above?([1, 2])
            assert_equal 28, diff1.size
            buf = diff1[24].gsub(/\r\n|\r|\n/, "")
            assert_equal "+    return true unless klass.respond_to?('watched_by')", buf
          else
            assert_equal 0, diff1.size
          end
          [4, 'def6d2f1254a'].each do |r2|
            diff2 = @adapter.diff(nil,r1,r2)
            assert_equal 49, diff2.size
            buf =  diff2[41].gsub(/\r\n|\r|\n/, "")
            assert_equal "+class WelcomeController < ApplicationController", buf
            diff3 = @adapter.diff('sources/watchers_controller.rb', r1, r2)
            assert_equal 20, diff3.size
            buf =  diff3[12].gsub(/\r\n|\r|\n/, "")
            assert_equal "+    @watched.remove_watcher(user)", buf
          end
        end
      end

      def test_cat
        [2, '400bb8672109', '400', 400].each do |r|
          buf = @adapter.cat('sources/welcome_controller.rb', r)
          assert buf
          lines = buf.split("\r\n")
          assert_equal 25, lines.length
          assert_equal 'class WelcomeController < ApplicationController', lines[17]
        end
        assert_nil @adapter.cat('sources/welcome_controller.rb')
      end

      def test_annotate
        assert_equal [], @adapter.annotate("sources/welcome_controller.rb").lines
        [2, '400bb8672109', '400', 400].each do |r|
          ann = @adapter.annotate('sources/welcome_controller.rb', r)
          assert ann
          assert_equal '1', ann.revisions[17].revision
          assert_equal '9d5b5b004199', ann.revisions[17].identifier
          assert_equal 'jsmith', ann.revisions[0].author
          assert_equal 25, ann.lines.length
          assert_equal 'class WelcomeController < ApplicationController', ann.lines[17]
        end
      end

      # TODO filesize etc.
      def test_entries
        assert_nil @adapter.entries(nil, '100000')
        [2, '400bb8672109', '400', 400].each do |r|
          entries1 = @adapter.entries(nil, r)
          assert entries1
          assert_equal 3, entries1.size
          assert_equal 'sources', entries1[1].name
          assert_equal 'sources', entries1[1].path
          assert_equal 'dir', entries1[1].kind
          assert_equal 'README', entries1[2].name
          assert_equal 'README', entries1[2].path
          assert_equal 'file', entries1[2].kind

          entries2 = @adapter.entries('sources', r)
          assert entries2
          assert_equal 2, entries2.size
          assert_equal 'watchers_controller.rb', entries2[0].name
          assert_equal 'sources/watchers_controller.rb', entries2[0].path
          assert_equal 'file', entries2[0].kind
          assert_equal 'welcome_controller.rb', entries2[1].name
          assert_equal 'sources/welcome_controller.rb', entries2[1].path
          assert_equal 'file', entries2[1].kind
        end
      end

      def test_access_by_nodeid
        path = 'sources/welcome_controller.rb'
        assert_equal @adapter.cat(path, 2), @adapter.cat(path, '400bb8672109')
      end

      def test_access_by_fuzzy_nodeid
        path = 'sources/welcome_controller.rb'
        # falls back to nodeid
        assert_equal @adapter.cat(path, 2), @adapter.cat(path, '400')
      end

      private

      def test_hgversion_for(hgversion, version)
        @adapter.class.expects(:hgversion_from_command_line).returns(hgversion)
        assert_equal version, @adapter.class.hgversion
      end

      def test_template_path_for(version, template)
        assert_equal "#{TEMPLATES_DIR}/#{TEMPLATE_NAME}-#{template}.#{TEMPLATE_EXTENSION}",
                     @adapter.class.template_path_for(version)
        assert File.exist?(@adapter.class.template_path_for(version))
      end
    else
      puts "Mercurial test repository NOT FOUND. Skipping unit tests !!!"
      def test_fake; assert true end
    end
  end

rescue LoadError
  class MercurialMochaFake < ActiveSupport::TestCase
    def test_fake; assert(false, "Requires mocha to run those tests")  end
  end
end

