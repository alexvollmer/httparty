require "spec/spec_helper"

describe "Hashpath Enumerable support" do

  before(:all) do
    @data = HTTParty::Hashpath.wrap([{ :name => "alpha" },
                                     { :name => "bravo" },
                                     { :name => "charlie" }])
  end

  describe "using 1.8 Enumerable operations" do

    it "should support :all?" do
      @data.all? { |x| x.name == "bacon" }.should be_false
      @data.all? { |x| String === x.name }.should be_true
    end

    it "should support :any?" do
      @data.any? { |x| x.name == "alpha" }.should be_true
      @data.any? { |x| x.name == "bacon" }.should be_false
    end

    it "should support :collect" do
      @data.collect { |x| x.name }.should == %w(alpha bravo charlie)
    end

    it "should support :map" do
      @data.map { |x| x.name }.should == %w(alpha bravo charlie)
    end

    it "should support :detect" do
      @data.detect { |x| x.name == "alpha" }.should == { :name => "alpha" }
      @data.detect { |x| x.name == "bacon" }.should be_nil
    end

    it "should support :find" do
      @data.find { |x| x.name == "alpha" }.should == { :name => "alpha" }
      @data.find { |x| x.name == "bacon" }.should be_nil
    end

    it "should support :each_with_index" do
      names = []
      @data.each_with_index { |e, i| names << "#{i} = #{e.name}" }
      names.should == ["0 = alpha", "1 = bravo", "2 = charlie"]
    end

    it "should support :find_all" do
      @data.find_all { |x| x.name =~ /[a-c]/ }.
        should == [{ :name => "alpha" },
                   { :name => "bravo" },
                   { :name => "charlie"}]

      @data.find_all { |x| x.name == "bacon" }.should be_empty
    end

    it "should support :select" do
      @data.select { |x| x.name =~ /[a-c]/ }.
        should == [{ :name => "alpha" },
                   { :name => "bravo" },
                   { :name => "charlie"}]

      @data.select { |x| x.name == "bacon" }.should be_empty
    end

    it "should support :inject" do
      @data.inject(0) { |memo, obj| memo + obj.name.size }.should == 17
    end

    it "should support :max" do
      @data.max { |a,b| a.name.size <=> b.name.size }.should == { :name => "charlie" }
    end

    it "should support :min" do
      @data.min { |a,b| a.name[0] <=> b.name[0] }.should == { :name => "alpha" }
    end

    it "should support :partition" do
      @data.partition { |x| x.name == "bravo" }.
        should == [ [{ :name => "bravo" }],
                    [{ :name => "alpha" }, { :name => "charlie"}] ]
    end


    it "should support :reject" do
      @data.reject { |x| x.name == "bravo" }.
        should == [{ :name => "alpha" }, { :name => "charlie" }]
    end

    it "should support :sort" do
      @data.sort { |a, b| b.name <=> a.name }.
        should == [{ :name => "charlie" }, { :name => "bravo" }, { :name => "alpha" }]
    end

    it "should support :sort_by" do
      @data.sort_by { |x| x.name }.should == [ { :name => "alpha" },
                                               { :name => "bravo" },
                                               { :name => "charlie" }]
    end

  end

  if RUBY_VERSION > "1.8.6"
    describe "using 1.9 Enumerable operations" do

      it "should support :count" do
        @data.count.should == 3

        @data.count({ :name => "alpha" }).should == 1
        @data.count({ :name => "bacon" }).should == 0

        @data.count { |x| x.name == "alpha" }.should == 1
        @data.count { |x| x.name == "bacon" }.should == 0
      end

      it "should support :cycle" do
        names = []
        @data.cycle(2) { |x| names << x.name }
        names.should == %w(alpha bravo charlie alpha bravo charlie)
      end

      it "should support :drop_while" do
        @data.drop_while { |x| x.name == "alpha" }.
          should == [ { :name => "bravo" }, { :name => "charlie" }]
      end

      it "should support :each_cons" do
        pairs = []
        @data.each_cons(2) { |a,b| pairs << [a.name, b.name]}
        pairs.should == [ ["alpha", "bravo"], ["bravo", "charlie"] ]
      end

      it "should support :each_slice" do
        names = []
        @data.each_slice(2) do |a,b|
          names << a.name
          names << b.name if b
        end
        names.should == ["alpha", "bravo", "charlie"]
      end

      it "should support :find_index" do
        @data.find_index { |x| x[:name] == "bravo" }.should == 1
        @data.find_index { |x| x.name == "bravo" }.should == 1
      end

      it "should support :group_by" do
        @data.group_by { |x| x.name == "alpha" ? "a" : "b" }.
          should == {
          "a" => [{ :name => "alpha" }],
          "b" => [{ :name => "bravo" }, { :name => "charlie" }]
        }
      end

      it "should support :max_by" do
        @data.max_by { |x| x.name.length }.should == { :name => "charlie" }
      end

      it "should support :min_by" do
        @data.min_by { |x| x.name[0] }.should == { :name => "alpha" }
      end

      it "should support :minmax" do
        @data.minmax { |a,b| a.name[0] <=> b.name[0] }.
          should == [{ :name => "alpha" }, { :name => "charlie" }]
      end

      it "should support :minmax_by" do
        @data.minmax_by { |x| x.name[0] }.
          should == [{ :name => "alpha" }, { :name => "charlie" }]
      end

      it "should support :none?" do
        @data.none? { |x| x.name == "alpha" }.should be_false
        @data.none? { |x| x.name == "bacon" }.should be_true
      end

      it "should support :one?" do
        @data.one? { |x| x.name == "alpha" }.should be_true
        @data.one? { |x| x.name.length == 5 }.should be_false
        @data.one? { |x| x.name == "bacon" }.should be_false
      end

      it "should support :reduce" do
        @data.inject(0) { |memo, obj| memo + obj.name.size }.should == 17
      end

      it "should support :reverse_each" do
        names = []
        @data.reverse_each { |x| names << x.name }
        names.should == %w(charlie bravo alpha)
      end

      it "should support :take_while" do
        @data.take_while { |x| x.name != "charlie" }.
          should == [{ :name => "alpha" }, { :name => "bravo" }]
      end

    end

  end

end
