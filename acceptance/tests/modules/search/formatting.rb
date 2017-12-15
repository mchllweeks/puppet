test_name 'puppet module search output should be well structured'

agents.each do |agent|
  skip_test('Skipping EC2 Hosts') if fact_on(agent, 'ec2_metadata')
end

tag 'audit:low',
    'audit:unit'

step 'Setup'
stub_forge_on(master)

step 'Search results should line up by column'
on master, puppet("module search apache") do

  assert_match(/Searching/, stdout.lines.first)
  columns = stdout.lines.to_a[1].split(/\s{2}(?=\S)/)
  pattern = /^#{ columns.map { |c| c.chomp.gsub(/./, '.') }.join('  ') }$/

  stdout.gsub(/\e.*?m/, '').lines.to_a[1..-1].each do |line|
    assert_match(pattern, line.chomp, 'columns were misaligned')
  end
end
