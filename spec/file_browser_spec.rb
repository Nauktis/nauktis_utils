require 'spec_helper'

describe NauktisUtils::FileBrowser do
  it 'sanitizes leading spaces' do
  	expect(NauktisUtils::FileBrowser.sanitize_name('   LeadingSpaceRemoved')).to eq('LeadingSpaceRemoved')
  end

  it 'sanitizes trailing spaces' do
  	expect(NauktisUtils::FileBrowser.sanitize_name('TrailingSpaceRemoved   ')).to eq('TrailingSpaceRemoved')
  end

  it 'sanitizes spaces' do
  	expect(NauktisUtils::FileBrowser.sanitize_name(" A l lSp a ce\tRe    mo \n ve d  ")).to eq('A_l_lSp_a_ce_Re_mo_ve_d')
  end

  it 'sanitizes repeated spaces' do
  	expect(NauktisUtils::FileBrowser.sanitize_name('Very      long       spaces')).to eq('Very_long_spaces')
  end

  it 'sanitizes new lines' do
  	expect(NauktisUtils::FileBrowser.sanitize_name("Two\nWords")).to eq('Two_Words')
  end

  it 'sanitizes tabs' do
  	expect(NauktisUtils::FileBrowser.sanitize_name("Two\tWords")).to eq('Two_Words')
  end

  it 'sanitizes but keeps . and -' do
  	expect(NauktisUtils::FileBrowser.sanitize_name("Keep_.-Chars")).to eq('Keep_.-Chars')
  end

  it 'sanitizes but keeps capitalized letters' do
  	expect(NauktisUtils::FileBrowser.sanitize_name("MajKept")).to eq('MajKept')
  end

  it 'sanitizes fancy characters' do
  	expect(NauktisUtils::FileBrowser.sanitize_name("C\'était ça mais où?")).to eq('Ctait_a_mais_o')
  end
end
