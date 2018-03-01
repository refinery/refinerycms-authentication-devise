require 'spec_helper'

module Refinery
  module Authentication
    module Devise
      describe 'path helpers' do
        describe '.root' do
          it 'contains the gemspec' do
            root_path = Refinery::Authentication::Devise.root
            gemspec_path = File.join(root_path, 'refinerycms-authentication-devise.gemspec')
            expect(File.exist?(gemspec_path)).to eq true
          end
        end

        describe '.factory_paths' do
          it 'has directories that exist' do
            factories_dir = Refinery::Authentication::Devise.factory_paths
            expect(factories_dir.all? { |factory_path| Dir.exist?(factory_path) })
          end
        end
      end
    end
  end
end
