require 'spec_helper'

describe NauktisUtils::FileDigester do
  it 'has correct hashes' do
    Dir.mktmpdir do |dir|
      a = create_file_with_content(dir, "ABC")
      expect(NauktisUtils::FileDigester.digest(a, 'md5')).to eq('902fbdd2b1df0c4f70b4a5d23525e932')
      expect(NauktisUtils::FileDigester.digest(a, 'sha1')).to eq('3c01bdbb26f358bab27f267924aa2c9a03fcfdb8')
      expect(NauktisUtils::FileDigester.digest(a, 'sha256')).to eq('b5d4045c3f466fa91fe2cc6abe79232a1a57cdf104f7a26e716e0a1e2789df78')
      expect(NauktisUtils::FileDigester.digest(a, 'sha512')).to eq('397118fdac8d83ad98813c50759c85b8c47565d8268bf10da483153b747a74743a58a90e85aa9f705ce6984ffc128db567489817e4092d050d8a1cc596ddc119')
      expect(NauktisUtils::FileDigester.digest(a, 'sha3')).to eq('7fb50120d9d1bc7504b4b7f1888d42ed98c0b47ab60a20bd4a2da7b2c1360efa')
    end
  end

  it 'has consistent file digest' do
    Dir.mktmpdir do |dir|
      a = create_file_with_content(dir, "ABC")
      b = create_file_with_content(dir, "ABC")
      c = create_file_with_content(dir, "DEF")

      ['md5', 'sha1', 'sha256', 'sha512', 'sha3'].each do |alg|
        a_dgst = NauktisUtils::FileDigester.digest(a, alg)
        expect(NauktisUtils::FileDigester.digest(b, alg)).to eq(a_dgst)
        expect(NauktisUtils::FileDigester.digest(c, alg)).not_to eq(a_dgst)
      end
    end
  end
end
