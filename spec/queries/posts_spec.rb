require 'rails_helper'

RSpec.describe Posts, type: :query do
  subject { described_class }

  let(:posts_with_params_query) do
    klass = Class.new(ApplicationQuery)
    klass.const_set(:MODEL, Post)
    klass.const_set(:SQL_FILE, Rails.root.join("app", "queries", "sql", "posts_with_params.sql"))
    stub_const("PostsWithParams", klass)
  end

  describe "#call" do
    it "returns an Array" do
      expect(subject.call).to be_an(Array)
    end

    it "returns one or more records" do
      3.times { Post.create(title: "Test Post", description: "Test Description") }
      expect(subject.call).to be_present
    end

    context "when query has required SQL params" do
      it "raises when params are missing" do
        expect { posts_with_params_query.call(status: "ok", z: "z") }.to raise_error(
          Queries::Errors::MissingRequiredParamsError,
          /Missing required params for PostsWithParams: missing=\[id\] received=\[status,z\]/
        )
      end

      it "treats nil params as empty hash" do
        expect { posts_with_params_query.call(nil) }.to raise_error(
          Queries::Errors::MissingRequiredParamsError,
          /Missing required params for PostsWithParams: missing=\[id,status\] received=\[\]/
        )
      end

      it "accepts string keys" do
        expect { posts_with_params_query.call({ "id" => 1, "status" => "z" }) }.not_to raise_error
      end

      it "accepts hash-like objects" do
        hash_like = Struct.new(:payload) do
          def to_h
            payload
          end
        end.new({ id: 1, status: "z" })

        expect { posts_with_params_query.call(hash_like) }.not_to raise_error
      end
    end

    describe "PostsWithParams edge behavior" do
      it "deduplicates repeated placeholders" do
        instance = posts_with_params_query.new({})
        allow(instance).to receive(:sql).and_return("select * from posts where id = :id and status = :status or status = :status")

        expect(instance.send(:required_param_names)).to eq([ "id", "status" ])
      end

      it "treats nil and false values as present" do
        expect { posts_with_params_query.call(id: nil, status: false) }.not_to raise_error
      end

      it "raises for non-hash-like params" do
        expect { posts_with_params_query.call(Object.new) }
          .to raise_error(ArgumentError, /Hash-like object or nil/)
      end

      it "raises when to_h does not return a Hash" do
        bad_hash_like = Struct.new(:payload) do
          def to_h
            payload
          end
        end.new("not-a-hash")

        expect { posts_with_params_query.call(bad_hash_like) }
          .to raise_error(ArgumentError, /Hash-like object or nil/)
      end

      it "ignores postgres casts when extracting placeholders" do
        instance = posts_with_params_query.new({})
        allow(instance).to receive(:sql).and_return("select created_at::timestamp from posts where id = :id")

        expect(instance.send(:required_param_names)).to eq([ "id" ])
      end

      it "treats placeholders in comments and literals as required (known limitation)" do
        instance = posts_with_params_query.new({ id: 1 })
        allow(instance).to receive(:sql).and_return("select * from posts where id = :id -- :ghost\nand note = ':also_ghost'")

        expect { instance.send(:validate_required_params!) }.to raise_error(
          Queries::Errors::MissingRequiredParamsError,
          /missing=\[also_ghost,ghost\] received=\[id\]/
        )
      end
    end
  end
end
