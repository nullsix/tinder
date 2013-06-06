shared_examples "instance method" do
  subject { instance }

  it "exists" do
    should respond_to method
  end
end

