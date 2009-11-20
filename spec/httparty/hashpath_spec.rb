require "spec/spec_helper"

describe "HTTParty::Hashpath.wrap" do

  describe "with a simple Hash" do
    before(:all) do
      @data1 = HTTParty::Hashpath.wrap({ :foo => "FOO", :bar => "BAR" })
      @data2 = HTTParty::Hashpath.wrap({ "foo" => "FOO", "bar" => "BAR" })
    end

    it "should still allow normal Hash access" do
      @data1[:foo].should == "FOO"
      @data1[:bar].should == "BAR"
      @data2["foo"].should == "FOO"
      @data2["bar"].should == "BAR"
    end

    it "should access key via accessor method" do
      @data1.foo.should == "FOO"
      @data1.bar.should == "BAR"
      @data2.foo.should == "FOO"
      @data2.bar.should == "BAR"
    end

    it "should return nil for missing keys" do
      @data1.dorkboy.should be_nil
      @data2.dorkboy.should be_nil
    end

    it "should still look like a Hash" do
      Hash.should === @data1
      Hash.should === @data2
    end
  end

  describe "with a nested Hash" do
    before(:all) do
      @data1 = HTTParty::Hashpath.wrap({:foo => {
                                           :name => "FOO",
                                           :description => "A thing that foos"},
                                         :bar => {
                                           :name => "BAR",
                                           :description => "A thing that bars"}})

      @data2 = HTTParty::Hashpath.wrap({"foo" => {
                                           "name" => "FOO",
                                           "description" => "A thing that foos"},
                                         "bar" => {
                                           "name" => "BAR",
                                           "description" => "A thing that bars"}})
    end

    it "should still allow normal Hash access" do
      @data1[:foo][:name].should == "FOO"
      @data1[:bar][:name].should == "BAR"
      @data2["foo"]["name"].should == "FOO"
      @data2["bar"]["name"].should == "BAR"
    end

    it "should return the sub-hash attributes directly" do
      @data1.foo.should == {
        :name => "FOO",
        :description => "A thing that foos"
      }

      @data1.bar.should == {
        :name => "BAR",
        :description => "A thing that bars"
      }

      @data2.foo.should == {
        "name" => "FOO",
        "description" => "A thing that foos"
      }

      @data2.bar.should == {
        "name" => "BAR",
        "description" => "A thing that bars"
      }
    end

    it "should access the sub-hash keys via accessor methods" do
      @data1.foo.name.should == "FOO"
      @data1.foo.description.should == "A thing that foos"
      @data1.bar.name.should == "BAR"
      @data1.bar.description.should == "A thing that bars"
    end

    it "should return nil for missing sub-hash keys" do
      @data1.foo.point_value.should be_nil
    end

    it "should still look like a Hash" do
      Hash.should === @data1.foo
      Hash.should === @data1.bar
    end
  end

  describe "with three levels of Hashes" do
    before(:all) do
      @data1 = HTTParty::Hashpath.wrap({:foo => {:bar => {:baz => "Howdy!"}}})
      @data2 = HTTParty::Hashpath.wrap({"foo" => {"bar" => {"baz" => "Howdy!"}}})
    end

    it "should still allow normal Hash access" do
      @data1[:foo][:bar][:baz].should == "Howdy!"
      @data2["foo"]["bar"]["baz"].should == "Howdy!"
    end

    it "should traverse three levels deep via accessor" do
      @data1.foo.bar.baz.should == "Howdy!"
      @data2.foo.bar.baz.should == "Howdy!"
    end
  end

  describe "with a Hash of Arrays" do
    before(:all) do
      @data1 = HTTParty::Hashpath.wrap(:foo => ["a", "b", "c"])
      @data2 = HTTParty::Hashpath.wrap("foo" => ["a", "b", "c"])
    end

    it "should still allow normal Hash access" do
      @data1[:foo].should == ["a", "b", "c"]
      @data2["foo"].should == ["a", "b", "c"]
    end

    it "should return an Array via the foo accessor" do
      @data1.foo.should == ["a", "b", "c"]
    end

    it "should treat leaf node as an Array" do
      @data1.foo[0].should == "a"
      @data1.foo[1].should == "b"
      @data1.foo[2].should == "c"
      @data1.foo.first.should == "a"
      @data1.foo.last.should == "c"
    end

  end

  describe "with a Hash of Arrays of Hashes" do
    before(:all) do
      @data1 = HTTParty::Hashpath.wrap({:foo => [{ :bar => "BAR" },
                                                 { :baz => "BAZ" }]})
      @data2 = HTTParty::Hashpath.wrap({"foo" => [{ "bar" => "BAR" },
                                                  { "baz" => "BAZ" }]})
    end

    it "should traverse three levels deep" do
      @data1.foo[0].bar.should == "BAR"
      @data1.foo[1].baz.should == "BAZ"
      @data1.foo.first.bar.should == "BAR"
      @data1.foo.last.baz.should == "BAZ"

      @data2.foo[0].bar.should == "BAR"
      @data2.foo[1].baz.should == "BAZ"
      @data2.foo.first.bar.should == "BAR"
      @data2.foo.last.baz.should == "BAZ"
    end
  end

  describe "with a deeply-nested Hash/Array structure with symbolic keys" do
    before(:all) do
      @data = HTTParty::Hashpath.wrap({:posts => [
                                                  { :title => "Post 1",
                                                    :comments => [ { :text => "Comment 1"},
                                                                   { :text => "Comment 2"}]},
                                                  { :title => "Post 2",
                                                    :comments => [{ :text => "Comment 3"},
                                                                  { :text => "Comment 4"}]
                                                  }]})
    end


    it "should traverse accessors correctly" do
      @data.posts.first.title.should == "Post 1"
      @data.posts.first.comments.first.text.should == "Comment 1"
      @data.posts.last.title.should == "Post 2"
      @data.posts.last.comments.last.text.should == "Comment 4"
    end
  end

  describe "with a deeply-nested Hash/Array structure with String keys" do
    before(:all) do
      @data = HTTParty::Hashpath.wrap({"posts" => [
                                                   { "title" => "Post 1",
                                                     "comments" => [ { "text" => "Comment 1"},
                                                                     { "text" => "Comment 2"}]},
                                                   { "title" => "Post 2",
                                                     "comments" => [{ "text" => "Comment 3"},
                                                                    { "text" => "Comment 4"}]
                                                   }]})
    end


    it "should traverse accessors correctly" do
      @data.posts.first.title.should == "Post 1"
      @data.posts.first.comments.first.text.should == "Comment 1"
      @data.posts.last.title.should == "Post 2"
      @data.posts.last.comments.last.text.should == "Comment 4"
    end
  end

  describe "with an Array" do
    before(:all) do
      @data = HTTParty::Hashpath.wrap([{ :name => "alpha" },
                                       { :name => "bravo" },
                                       { :name => "charlie" }])
    end

    it "should still look like an Array" do
      Array.should === @data
      @data.should be_kind_of(Array)
    end

    it "should allow dot-syntax via :each" do
      names = []
      @data.each { |x| names << x.name }
      names.should == %w(alpha bravo charlie)
    end

  end

end
