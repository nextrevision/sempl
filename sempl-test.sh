source ./sempl

describe "test private functions"
it_displays_usage() {
  cmd "_usage"
  assert_rc 0
  assert_content "usage: "
  assert_content "-h "
}
it_displays_verbose() {
  cmd "__sempl_verbose=1 _verbose 'test out'"
  assert_rc 0
  assert_content "test out"
}
it_is_not_verbose() {
  cmd "__sempl_verbose=0 _verbose 'test out'"
  assert_content_not "test out"
}
it_displays_error() {
  cmd "_error 'test error'"
  assert_rc 1
  assert_content "ERROR: test error"
}
it_cleans_unencrypted_files() {
  touch test.unenc
  cmd "__sempl_varsfile=test.unenc _clean"
  assert_rc 0
  ! test -f test.unenc
}

describe "test cli flags"
it_errors_without_args() {
  cmd "_main"
  assert_rc 1
  assert_content "usage: "
}
it_errors_without_template() {
  cmd "_main -v"
  assert_rc 1
  assert_content "ERROR: "
}
it_errors_with_nonexistent_template() {
  cmd "_main nosuchfile"
  assert_rc 1
  assert_content "ERROR: "
}
it_converts_template() {
  cmd "_main -o ./test/fixtures/001_variable_default.tmpl"
  assert_rc 0
  assert_content "testvar=defaultvalue"
}
it_errors_when_varsfile_is_not_found() {
  cmd "_main -o -s nosuchfile ./test/fixtures/009_varsfile.tmpl"
  assert_rc 1
  assert_content "ERROR: "
}
it_errors_when_varsfile_is_not_found() {
  cmd "_main -o -s nosuchfile ./test/fixtures/009_varsfile.tmpl"
  assert_rc 1
  assert_content "ERROR: "
}
it_sources_varsfile() {
  cmd "_main -o -s ./test/fixtures/varsfile.txt ./test/fixtures/009_varsfile.tmpl"
  assert_rc 0
  assert_content "testvar=sourcedvalue"
}
it_sources_encrypted_varsfile_from_pass() {
  cmd "_main -o -p password -s ./test/fixtures/varsfile.enc ./test/fixtures/009_varsfile.tmpl"
  assert_rc 0
  assert_content "testvar=sourcedvalue"
}
it_sources_encrypted_varsfile_from_passfile() {
  echo "password" > passfile
  cmd "_main -o -k passfile -s ./test/fixtures/varsfile.enc ./test/fixtures/009_varsfile.tmpl"
  assert_rc 0
  assert_content "testvar=sourcedvalue"
  rm passfile
}
it_sources_varsfile_with_bad_password() {
  cmd "_main -o -p badpass -s ./test/fixtures/varsfile.enc ./test/fixtures/009_varsfile.tmpl"
  assert_rc 1
  assert_content "ERROR: "
}

describe "test template conversion"
it_converts_template_001_variable_default() {
  cmd "__sempl_template=./test/fixtures/001_variable_default.tmpl __sempl_outfile=/dev/stdout _convert_template"
  assert_rc 0
  assert_content "testvar=defaultvalue"
}
it_converts_template_002_variable_escaping() {
  cmd "__sempl_template=./test/fixtures/002_variable_escaping.tmpl __sempl_outfile=/dev/stdout _convert_template"
  assert_rc 0
  assert_content 'testvar=$testvar'
}
it_converts_template_003_variable_expansion() {
  cmd "testvar=testvalue __sempl_template=./test/fixtures/003_variable_expansion.tmpl __sempl_outfile=/dev/stdout _convert_template"
  assert_rc 0
  assert_content 'testvar=testvalue'
}
it_converts_template_004_variable_expansion() {
  cmd "testvar=testvalue __sempl_template=./test/fixtures/004_variable_expansion.tmpl __sempl_outfile=/dev/stdout _convert_template"
  assert_rc 0
  assert_content 'testvar=testvalue'
}
it_converts_template_005_double_quote() {
  cmd "testvar=testvalue __sempl_template=./test/fixtures/005_double_quote.tmpl __sempl_outfile=/dev/stdout _convert_template"
  assert_rc 0
  assert_content 'testvar="testvalue"'
}
it_converts_template_006_single_quote() {
  cmd "testvar=testvalue __sempl_template=./test/fixtures/006_single_quote.tmpl __sempl_outfile=/dev/stdout _convert_template"
  assert_rc 0
  assert_content "testvar='testvalue'"
}
it_converts_template_007_bash_inline() {
  cmd "testvar=testvalue __sempl_template=./test/fixtures/007_bash_inline.tmpl __sempl_outfile=/dev/stdout _convert_template"
  assert_rc 0
  assert_content 'testvar="inline"'
}
it_converts_template_008_bash_loop() {
  cmd "testvar=testvalue __sempl_template=./test/fixtures/008_bash_loop.tmpl __sempl_outfile=/dev/stdout _convert_template"
  assert_rc 0
  assert_regex '^  1$'
  assert_regex '^  2$'
  assert_regex '^  3$'
}
