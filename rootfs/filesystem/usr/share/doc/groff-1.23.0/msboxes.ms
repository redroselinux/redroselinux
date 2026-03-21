.\" groff -ms -msboxes -Tpdf
.nr LL 17c
.nr PO 2c
.nr PS 11
.nr VS 13
.nr PI 3.5n
.nr HM 2c
.nr FM 2c
.nr QI 7n
.ss 12 0
.ND March 2021
.EH '%''March 2021'
.EF ''''
.OH 'Using PDF boxes with \f[I]groff\f[] and the \f[I]ms\f[] macros''%'
.OF ''''
.\" Define a quotation macro.
.de Qq
.  nop \[lq]\\$1\[rq]\\$2
..
.\" Define a macro for code literals; use bold and disable hyphenation.
.de Lt
.  ft B
.  nh
.  nop \&\\$1\c
.  hy \\n[HY]
.  ft
.  nop \&\\$2
..
.ds FAM H
.TL
Using PDF boxes with
.BI groff
and the
.BI ms
macros
.AU
Deri James
.AI
deri@chuzzlewit.myzen.co.uk
.LP
An extension in version 1.23.0 of
.I gropdf ,
the PDF output driver for the
.I groff
document formatting system,
allows coloured rectangles to be placed beneath any output created by
.I groff .
The extension can be accessed via a device control escape sequence
.Lt "\[rs]X\[aq]pdf: background" \~.\|.\|.\|\c
.Lt \[aq]
or a convenience macro
.Lt pdfbackground
supporting the same parameters.
.QS
.BOXSTART SHADED cornsilk OUTLINED brown INDENT 2n WEIGHT 1p
\M[floralwhite]\c
.pdfbackground pagefill
\M[]\c
.B
\[rs]X\[aq]pdf: background
.BI
cmd left top right bottom weight\[aq]
.br
.Lt .pdfbackground
.BI
cmd left top right bottom weight
.LP
each produce a background rectangle on the page, where
.IP \f[I]cmd 8n \" indent enough to fit "bottom" tag
is the command, which can be any of
.Qq page|fill|box
in combination.
Thus,
.Qq pagefill
would draw a rectangle which covers the whole current page size (in
which case the rest of the parameters can be omitted because the box
dimensions are taken from the current media size).
.Qq boxfill ,
on the other hand, requires the given dimensions to place the box.
Including
.Qq fill
in the command will paint the rectangle with the current fill colour (as
with
.Lt \[rs]M[] )
and including
.Qq box
will give the rectangle a border in the current stroke colour
(as with
.Lt \[rs]m[] ).
.sp \n[PD]u
.I cmd
may also be
.Qq off
on its own, which will terminate drawing the current box.
If you have specified a page colour with
.Qq pagefill ,
it is always the first box in the stack, and if you specify it again, it
will replace the first entry.
Be aware that the
.Qq pagefill
box renders the page opaque, so tools that
.Qq watermark
PDF pages are unlikely to be successful.
To return the background to transparent, issue an
.Qq off
command with no other boxes open.
.sp \n[PD]u
Finally,
.I cmd
may be
.Qq footnote
followed by a new value for
.I bottom ,
which will be used for all open boxes on the current page.
This is to allow room for footnote areas that grow while a page is
processed (to accommodate multiple footnotes,
for instance).\m[red]\**\m[]\" FOOTNOTE
.FS
If the value is negative, it is used as an offset from the bottom of the
page.
.FE
.nr oldPD \n[PD]
.nr PD 0
.IP \f[I]left
.IP \f[I]top
.IP \f[I]right
.IP \f[I]bottom
.nr PD \n[oldPD]
are the coordinates of the box.
The
.I top
and
.I bottom
coordinates are the minimum and maximum for the box, since the actual
start of the box is
.I groff 's
drawing position when you issue the command, and the bottom of the box
is the point where you turn the box
.Qq off .
The top and bottom coordinates are used only if the box drawing extends
onto the next page; ordinarily, they would be set to the header and
footer margins.
.IP \f[I]weight
provides the line width for the border if
.Qq box
is included in the command.
.BOXSTOP
.QE
For an even more convenient interface, include
.Lt \-msboxes
on the
.I groff
command line; the
.I sboxes
package defines the macros
.Lt BOXSTART
and
.Lt BOXSTOP .
.QS
.BOXSTART SHADED cornsilk OUTLINED brown INDENT 2n WEIGHT 1p
.BOXSTART SHADED cornsilk3 INDENT 2p
.Lt .BOXSTART
.Lt SHADED
.I colour
.Lt OUTLINED
.I colour
.Lt INDENT
.I size
.Lt WEIGHT
.I size
.BOXSTOP
.LP
begins a box,
where the argument after
.Lt SHADED
gives the fill colour and that after
.Lt OUTLINED
the border colour.
Omit the former to get a borderless filled box and the latter for a
border with no fill.
The specified
.Lt WEIGHT
is used if the box is
.Lt OUTLINED .
.LP
.Lt INDENT
precedes a value which leaves a gap between the border and the contents
inside the box.
.LP
Each
.I colour
must be a defined
.I groff
colour name,
and each
.I size
a valid
.I groff
numeric expression.
The keyword/value pairs can be specified in any order.
.BOXSTOP
.QE
Boxes can be stacked, so you can start a box within another box; usually
the later boxes would be smaller than the containing box, but this is
not enforced.
When using
.Lt BOXSTART ,
the left position is the current indent minus the
.Lt INDENT
in the command,
and the right position is the left position (calculated above) plus the
current line length and twice the indent.
The synopsis of
.Lt BOXSTART
above itself uses a
.Lt BOXSTART
call without borders and with a
.Lt 2p
(two point) indent.
.QS
.BOXSTART SHADED cornsilk OUTLINED brown INDENT 2n WEIGHT 1p
.BOXSTART SHADED cornsilk3 INDENT 2p
.Lt .BOXSTOP
.BOXSTOP
.LP
takes no parameters.
It closes the most recently started box at the current vertical position
after adding its
.Lt INDENT
spacing.
.BOXSTOP
.QE
Your
.I groff
documents can conditionally exercise the
.I sboxes
macros.
The register
.Lt GSBOX
is defined if the package is loaded, and interpolates a true value if
the
.Lt pdf
output device is in use.
.LP
.I sboxes
furthermore hooks into the
.I "groff ms"
package to receive notifications when footnotes are growing, so that it
can close boxes on a page before footnotes are printed.
When that condition obtains,
.I sboxes
will close open boxes two points\**
.FS
This amount probably will not match the box's
.Lt INDENT .
.FE
above the footnote separator and re-open them on the next page.
.LP
This document was produced using the following code.
.ds FAM C
.nr PS 11
.nr VS 13
.LP
.BOXSTART SHADED white OUTLINED brown INDENT 2n WEIGHT 1p
.nf
\# REPLACEME
\&.\[rs]" groff \-ms \-msboxes \-Tpdf
\&.nr LL 17c
\&.nr PO 2c
\&.nr PS 11
\&.nr VS 13
\&.nr PI 3.5n
\&.nr HM 2c
\&.nr FM 2c
\&.nr QI 7n
\&.ss 12 0
\&.ND March 2021
\&.EH \[aq]%\[aq]\[aq]March 2021\[aq]
\&.EF \[aq]\[aq]\[aq]\[aq]
\&.OH \[aq]Using PDF boxes with \[rs]f[I]groff\[rs]f[] and the \[rs]f[I]ms\[rs]f[] macros\[aq]\[aq]%\[aq]
\&.OF \[aq]\[aq]\[aq]\[aq]
\&.\[rs]" Define a quotation macro.
\&.de Qq
\&.  nop \[rs][lq]\[rs]\[rs]$1\[rs][rq]\[rs]\[rs]$2
\&..
\&.\[rs]" Define a macro for code literals; use bold and disable hyphenation.
\&.de Lt
\&.  ft B
\&.  nh
\&.  nop \[rs]&\[rs]\[rs]$1\[rs]c
\&.  hy \[rs]\[rs]n[HY]
\&.  ft
\&.  nop \[rs]&\[rs]\[rs]$2
\&..
\&.ds FAM H
\&.TL
Using PDF boxes with
\&.BI groff
and the
\&.BI ms
macros
\&.AU
Deri James
\&.AI
deri@chuzzlewit.myzen.co.uk
\&.LP
An extension in version 1.23.0 of
\&.I gropdf ,
the PDF output driver for the
\&.I groff
document formatting system,
allows coloured rectangles to be placed beneath any output created by
\&.I groff .
The extension can be accessed via a device control escape sequence
\&.Lt "\[rs][rs]X\[rs][aq]pdf: background" \[rs]\[ti].\[rs]|.\[rs]|.\[rs]|\[rs]c
\&.Lt \[rs][aq]
or a convenience macro
\&.Lt pdfbackground
supporting the same parameters.
\&.QS
\&.BOXSTART SHADED cornsilk OUTLINED brown INDENT 2n WEIGHT 1p
\[rs]M[floralwhite]\[rs]c
\&.pdfbackground pagefill
\[rs]M[]\[rs]c
\&.B
\[rs][rs]X\[rs][aq]pdf: background
\&.BI
cmd left top right bottom weight\[rs][aq]
\&.br
\&.Lt .pdfbackground
\&.BI
cmd left top right bottom weight
\&.LP
each produce a background rectangle on the page, where
\&.IP \[rs]f[I]cmd 8n \[rs]" indent enough to fit "bottom" tag
is the command, which can be any of
\&.Qq page|fill|box
in combination.
Thus,
\&.Qq pagefill
would draw a rectangle which covers the whole current page size (in
which case the rest of the parameters can be omitted because the box
dimensions are taken from the current media size).
\&.Qq boxfill ,
on the other hand, requires the given dimensions to place the box.
Including
\&.Qq fill
in the command will paint the rectangle with the current fill colour (as
with
\&.Lt \[rs][rs]M[] )
and including
\&.Qq box
will give the rectangle a border in the current stroke colour
(as with
\&.Lt \[rs][rs]m[] ).
\&.sp \[rs]n[PD]u
\&.I cmd
may also be
\&.Qq off
on its own, which will terminate drawing the current box.
If you have specified a page colour with
\&.Qq pagefill ,
it is always the first box in the stack, and if you specify it again, it
will replace the first entry.
Be aware that the
\&.Qq pagefill
box renders the page opaque, so tools that
\&.Qq watermark
PDF pages are unlikely to be successful.
To return the background to transparent, issue an
\&.Qq off
command with no other boxes open.
\&.sp \[rs]n[PD]u
Finally,
\&.I cmd
may be
\&.Qq footnote
followed by a new value for
\&.I bottom ,
which will be used for all open boxes on the current page.
This is to allow room for footnote areas that grow while a page is
processed (to accommodate multiple footnotes,
for instance).\[rs]m[red]\[rs]**\[rs]m[]\m[red]\**\m[]
.FS
This is a long footnote occupying multiple output lines.
Its only purpose is to verify that the bottom of the box on this page
has been adjusted upwards to accommodate it.
.FE
\&.FS
If the value is negative, it is used as an offset from the bottom of the
page.
\&.FE
\&.nr oldPD \[rs]n[PD]
\&.nr PD 0
\&.IP \[rs]f[I]left
\&.IP \[rs]f[I]top
\&.IP \[rs]f[I]right
\&.IP \[rs]f[I]bottom
\&.nr PD \[rs]n[oldPD]
are the coordinates of the box.
The
\&.I top
and
\&.I bottom
coordinates are the minimum and maximum for the box, since the actual
start of the box is
\&.I groff \[aq]s
drawing position when you issue the command, and the bottom of the box
is the point where you turn the box
\&.Qq off .
The top and bottom coordinates are used only if the box drawing extends
onto the next page; ordinarily, they would be set to the header and
footer margins.
\&.IP \[rs]f[I]weight
provides the line width for the border if
\&.Qq box
is included in the command.
\&.BOXSTOP
\&.QE
For an even more convenient interface, include
\&.Lt \[rs]\-msboxes
on the
\&.I groff
command line; the
\&.I sboxes
package defines the macros
\&.Lt BOXSTART
and
\&.Lt BOXSTOP .
\&.QS
\&.BOXSTART SHADED cornsilk OUTLINED brown INDENT 2n WEIGHT 1p
\&.BOXSTART SHADED cornsilk3 INDENT 2p
\&.Lt .BOXSTART
\&.Lt SHADED
\&.I colour
\&.Lt OUTLINED
\&.I colour
\&.Lt INDENT
\&.I size
\&.Lt WEIGHT
\&.I size
\&.BOXSTOP
\&.LP
begins a box,
where the argument after
\&.Lt SHADED
gives the fill colour and that after
\&.Lt OUTLINED
the border colour.
Omit the former to get a borderless filled box and the latter for a
border with no fill.
The specified
\&.Lt WEIGHT
is used if the box is
\&.Lt OUTLINED .
\&.LP
\&.Lt INDENT
precedes a value which leaves a gap between the border and the contents
inside the box.
\&.LP
Each
\&.I colour
must be a defined
\&.I groff
colour name,
and each
\&.I size
a valid
\&.I groff
numeric expression.
The keyword/value pairs can be specified in any order.
\&.BOXSTOP
\&.QE
Boxes can be stacked, so you can start a box within another box; usually
the later boxes would be smaller than the containing box, but this is
not enforced.
When using
\&.Lt BOXSTART ,
the left position is the current indent minus the
\&.Lt INDENT
in the command,
and the right position is the left position (calculated above) plus the
current line length and twice the indent.
The synopsis of
\&.Lt BOXSTART
above itself uses a
\&.Lt BOXSTART
call without borders and with a
\&.Lt 2p
(two point) indent.
\&.QS
\&.BOXSTART SHADED cornsilk OUTLINED brown INDENT 2n WEIGHT 1p
\&.BOXSTART SHADED cornsilk3 INDENT 2p
\&.Lt .BOXSTOP
\&.BOXSTOP
\&.LP
takes no parameters.
It closes the most recently started box at the current vertical position
after adding its
\&.Lt INDENT
spacing.
\&.BOXSTOP
\&.QE
Your
\&.I groff
documents can conditionally exercise the
\&.I sboxes
macros.
The register
\&.Lt GSBOX
is defined if the package is loaded, and interpolates a true value if
the
\&.Lt pdf
output device is in use.
\&.LP
\&.I sboxes
furthermore hooks into the
\&.I "groff ms"
package to receive notifications when footnotes are growing, so that it
can close boxes on a page before footnotes are printed.
When that condition obtains,
\&.I sboxes
will close open boxes two points\[rs]**
\&.FS
This amount probably will not match the box\[aq]s
\&.Lt INDENT .
\&.FE
above the footnote separator and re\-open them on the next page.
\&.LP
This document was produced using the following code.
\&.ds FAM C
\&.nr PS 11
\&.nr VS 13
\&.LP
\&.BOXSTART SHADED white OUTLINED brown INDENT 2n WEIGHT 1p
\&.nf
\[rs]# (replaced by source of this document)
\&.BOXSTOP
\&.\[rs]" Local Variables:
\&.\[rs]" mode: nroff
\&.\[rs]" fill\-column: 72
\&.\[rs]" End:
\&.\[rs]" vim: set filetype=groff textwidth=72:
\# REPLACEME
.BOXSTOP
.\" Local Variables:
.\" mode: nroff
.\" fill-column: 72
.\" End:
.\" vim: set filetype=groff textwidth=72:
