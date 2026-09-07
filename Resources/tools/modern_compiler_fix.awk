# modern_compiler_fix.awk - drop the running-header furniture folio.awk leaves
# in Modern Compiler Implementation in C (book_fix / $FIXAWK stage).
#
# The book prints an all-caps running head on (nearly) every body page, e.g.
# "CHAPTER ONE. INTRODUCTION", "CHAPTER ELEVEN. REGISTER ALLOCATION". Each stem
# carries the chapter's spelled-out number, so folio.awk's page vote (it needs a
# repeated stem across >= 4 dense pages) removes most but leaks 253 book-wide,
# one per page, occasionally landing mid-figure. The all-caps "CHAPTER <WORD>."
# form appears ONLY in the running head: the body and the real chapter headings
# use the mixed-case "Chapter N" / "1 Introduction" forms, so this shape has
# zero false positives against prose (verified: 253 matches, all heads).
# Line-drop only; the pipeline's trailing `cat -s` collapses the freed blank.

/^[ \t]*CHAPTER (ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN|EIGHT|NINE|TEN|ELEVEN|TWELVE|THIRTEEN|FOURTEEN|FIFTEEN|SIXTEEN|SEVENTEEN|EIGHTEEN|NINETEEN|TWENTY|TWENTY-ONE)\.[ \t]+[A-Z][A-Z '-]*[ \t]*$/ { next }
{ print }
