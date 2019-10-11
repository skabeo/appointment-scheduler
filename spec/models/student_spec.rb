require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'Validations' do

    subject {described_class.new}

    context 'validates name is present' do
      it 'succeeds w/name' do
        subject.name = 'Charlie Chan'
        expect(subject.save).to be_truthy
      end

      it 'fails without name' do
        subject.name = ''
        expect(subject.save).to be_falsey
      end
    end
  end
end
