require 'pdf-reader'
require 'date'

# Retrieve all pdf files in pdfin
files = Dir.glob("./pdfin/*").map{ |s| File.basename(s) }
files.each  do |x|
  puts "Got file called '#{x}'"
  reader = PDF::Reader.new("pdfin/#{x}")
  #puts reader.page_count
  stri = ""
  reader.pages.each do |page|
    str=page.text
    stri+=page.text
  end
  #generic:
  #puts stri.scan(/Invoice number: (\d{12}).*?Date: (\S*).*?Total: \$(\S*).*?End/m)
  
  #New style
  stri.scan(/Invoice\s*?Invoice # [\w-]*? \| .*?FAQs/m).each do |y|
    # y is a full matched invoice

    #generic
    #invoicen, invoiced, invoicet = y.match(/Invoice number: (\d{12}).*?Date: (\S*).*?Total: \$(\S*).*?End/m).captures
    #New style
    invoicen, invoiced, linepol, invoicet = y.match(/Invoice\s*?Invoice # ([\w-]*?) \|\s*(\w+ \d\d, \d\d\d\d).*PO # (POL-\d+).*?Amount due\s*\$\s?(\d+.\d+)/m).captures
    # Try to deal with a POL of "Morning!"
    #invoicen, invoiced, linepol, invoicet = y.match(/Invoice\s*?Invoice # ([\w-]*?) \|\s*(\w+ \d\d, \d\d\d\d).*PO # (POL-\d+|Morning!).*?Amount due\s*\$\s?(\d+.\d+)/m).captures 
    #What we have Mmmmmm dd, yyyy; what we want for invoicenewd: yyyymmdd; what we want for invoicenewbriefd: yymmdd.
    invoicenewd = Date.parse(invoiced).strftime('%Y%m%d')
    invoicenewbriefd = Date.parse(invoiced).strftime('%y%m%d')
    #puts "Inv No: #{invoicen} Inv Date: #{invoicenewd} Inv Total: #{invoicet} POL: #{linepol} \n"

    #get shipping
    #shipping = y.match(/Shipping & handling\s+\$/s+([\d.]+)/m).captures
    if matchdata = y.match(/Shipping & handling\s+\$\s+([\d.]+)/m)
      shipping = matchdata[1]
    else
      shipping = "0.00"
    end

    #get the lines
    lines = ""
    #generic
    #y.scan(/Line .*?\$\S+ PO line: \S+/m).each_with_index do |z, i|
    #Newstyle
    y.scan(/Invoice details.*FAQs/m).each_with_index do |z, i|
      # z is a full matched line. Actually, in the new format it's the lines section of the invoice.
      #generic
      #linepricematch = /Price: \$(\S+)/.match(z)

      #Newstyle
      #puts z
      #linepricematch = /(\d+)y?\s+\$[\d.]+\s+\$([\d.]+)\s+[\d.]+%\s+/.match(z)
      # The following modification to the line regex was for an issue where there was an 'l' (the letter L as in llama) after the quantity.
      #linepricematch = /(\d+)l?\s+\$[\d.]+\s+\$([\d.]+)\s+[\d.]+%\s+/.match(z)
      linepricematch = /(\d+)\s+\$[\d.]+\s+\$([\d.]+)\s+[\d.]+%\s+/.match(z)
      qty = linepricematch[1]
      lineprice = linepricematch[2]

      #puts "Lineprice: #{lineprice} Qty: #{qty} Linepol: #{linepol}"
      linen = i+1
      ##puts "Line No: #{linen} Line Price: #{lineprice} Line POL: #{linepol}"
      ##puts "ENDLINE"
      #lines += "LIN+#{linen}'QTY+47:1'MOA+203:#{lineprice}'PRI+AAB:#{lineprice}'RFF+LI:#{linepol}'"
      lines += <<-LINECONTENT
LIN+#{linen}'
QTY+47:#{qty}'
MOA+203:#{lineprice}'
PRI+AAB:#{lineprice}'
RFF+LI:#{linepol}'
LINECONTENT
      #puts lines
    end
    # Create an EDI file for the invoice

    edifile = <<-EDICONTENT
UNA:+.? '
UNB+UNOC:3+AMAZ:31B+TCCD:ZZ+#{invoicenewbriefd}:1631+0001'
UNH++INVOIC:D:96A:UN:EAN008'
BGM+380:::JINV+#{invoicen}+43'
DTM+137:#{invoicenewd}:102'
MOA+8:#{shipping}'
CUX+2:USD:4'
#{lines}UNS+S'
CNT+2:2'
MOA+79:#{invoicet}'
MOA+9:#{invoicet}'
UNT+23+#{invoicen}'
UNZ+3+0001'
EDICONTENT

    #puts edifile
    File.open("./ediout/#{invoicen}.edi", "w")
    File.write("./ediout/#{invoicen}.edi", "#{edifile}")
  end
end
