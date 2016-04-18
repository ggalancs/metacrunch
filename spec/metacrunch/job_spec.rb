describe Metacrunch::Job do

  describe ".define" do

    context "when called with a block" do
      let(:job) do
         Metacrunch::Job.define {}
      end

      it "creates a job" do
        expect(job).to be_a(Metacrunch::Job)
      end
    end

    context "when called with a valid string (a string containing valid job DSL ruby code)" do
      let(:job) do
        script = <<-EOT
          require "metacrunch/test_utils"
          source Metacrunch::TestUtils::DummySource.new
          destination Metacrunch::TestUtils::DummyDestination.new
          pre_process ->() { @pre_process_called = true }
          transformation ->(row) { @transformation_called = true }
          post_process ->() { @post_process_called = true }
        EOT

        Metacrunch::Job.define(script)
      end

      it "creates a job" do
        expect(job).to be_a(Metacrunch::Job)
      end
    end

    context "when called with an invalid string (a string containing invalid job DSL ruby code)" do
      let(:job) do
        script = <<-EOT
          This a not valid ruby code
        EOT

        Metacrunch::Job.define(script)
      end

      it "throws an exception" do
        expect{job}.to raise_error(SyntaxError)
      end
    end

  end

  describe "#add_pre_process" do
    let!(:job) { Metacrunch::Job.new }

    context "when called with a callable" do
      it "adds the callable as a pre_process" do
        job.add_pre_process(Metacrunch::TestUtils::DummyCallable.new)
        expect(job.pre_processes.count).to eq(1)
      end
    end

    context "when called with a block" do
      it "adds the block as a pre_process" do
        job.add_pre_process do ; end
        expect(job.pre_processes.count).to eq(1)
      end
    end

    context "when called with an object that does't respond to #call" do
      it "raises an error" do
        expect{
          job.add_pre_process(Metacrunch::TestUtils::DummyNonCallable.new)
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#pre_processes" do
    context "when no pre processes are defined" do
      let(:job) do
        Metacrunch::Job.define{}.run
      end

      it "returns an empty array" do
        expect(job.pre_processes).to eq([])
      end
    end

    context "when pre processes are defined" do
      let(:job) do
        Metacrunch::Job.define do
          pre_process ->() {}
          pre_process ->() {}
        end.run
      end

      it "returns the pre process instances" do
        expect(job.pre_processes.count).to eq(2)
      end
    end
  end


  describe "#post_processes" do
    context "when no post processes are defined" do
      let(:job) do
        Metacrunch::Job.define{}.run
      end

      it "returns an empty array" do
        expect(job.post_processes).to eq([])
      end
    end

    context "when post processes are defined" do
      let(:job) do
        Metacrunch::Job.define do
          post_process ->() {}
          post_process ->() {}
        end.run
      end

      it "returns the post process instances" do
        expect(job.post_processes.count).to eq(2)
      end
    end
  end


  describe "#sources" do
    context "when no sources are defined" do
      let(:job) do
        Metacrunch::Job.define{}.run
      end

      it "returns an empty array" do
        expect(job.sources).to eq([])
      end
    end

    context "when sources are defined" do
      let(:job) do
        Metacrunch::Job.define do
          require "metacrunch/test_utils"
          source Metacrunch::TestUtils::DummySource.new
          source Metacrunch::TestUtils::DummySource.new
        end.run
      end

      it "returns the source instances" do
        expect(job.sources.count).to eq(2)
      end
    end
  end


  describe "#destinations" do
    context "when no destinations are defined" do
      let(:job) do
        Metacrunch::Job.define{}.run
      end

      it "returns an empty array" do
        expect(job.destinations).to eq([])
      end
    end

    context "when destinations are defined" do
      let(:job) do
        Metacrunch::Job.define do
          require "metacrunch/test_utils"
          destination Metacrunch::TestUtils::DummyDestination.new
          destination Metacrunch::TestUtils::DummyDestination.new
        end.run
      end

      it "returns the destination instances" do
        expect(job.destinations.count).to eq(2)
      end
    end
  end


  describe "#transformations" do
    context "when no transformations are defined" do
      let(:job) do
        Metacrunch::Job.define{}.run
      end

      it "returns an empty array" do
        expect(job.transformations).to eq([])
      end
    end

    context "when transformations are defined" do
      let(:job) do
        Metacrunch::Job.define do
          transformation ->() {}
          transformation ->() {}
        end.run
      end

      it "returns the transformation instances" do
        expect(job.transformations.count).to eq(2)
      end
    end
  end


  describe "#run" do
    context "when source is defined" do
      let!(:job) do
        Metacrunch::Job.define do
          require "metacrunch/test_utils"
          source Metacrunch::TestUtils::DummySource.new
          destination Metacrunch::TestUtils::DummyDestination.new
          pre_process ->() { @pre_process_called = true }
          transformation ->(row) { @transformation_called = true }
          post_process ->() { @post_process_called = true }
        end.run
      end

      it "runs pre processes" do
        expect(job.builder.instance_variable_get("@pre_process_called")).to be(true)
      end

      it "runs post processes" do
        expect(job.builder.instance_variable_get("@post_process_called")).to be(true)
      end

      it "runs transformations" do
        expect(job.builder.instance_variable_get("@transformation_called")).to be(true)
      end

      it "writes to a destination" do
        expect(job.destinations.first.instance_variable_get("@write_called")).to be(true)
      end

      it "closes a destination" do
        expect(job.destinations.first.instance_variable_get("@close_called")).to be(true)
      end
    end

    context "when source is not defined" do
      let!(:job) do
        Metacrunch::Job.define do
          destination Metacrunch::TestUtils::DummyDestination.new
          pre_process ->() { @pre_process_called = true }
          transformation ->() { @transformation_called = true }
          post_process ->() { @post_process_called = true }
        end.run
      end

      it "runs pre processes" do
        expect(job.builder.instance_variable_get("@pre_process_called")).to be(true)
      end

      it "runs post processes" do
        expect(job.builder.instance_variable_get("@post_process_called")).to be(true)
      end

      it "does not run transformations" do
        expect(job.builder.instance_variable_get("@transformation_called")).to be_nil
      end

      it "does not run write to a destination" do
        expect(job.destinations.first.instance_variable_get("@write_called")).to be_nil
      end

      it "closes a destination" do
        expect(job.destinations.first.instance_variable_get("@close_called")).to be(true)
      end
    end
  end

end
