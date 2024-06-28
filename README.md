# pita-ruby

## Getting started

Clone the repository  
```git clone [code from above]``` 

cd into pita-ruby  
```cd pita-ruby```

You may need to install the pdf-reader gem.

```gem install pdf-reader```

## Run the program
Put the PDF file or files of invoices into the `pdfin` folder before running the program.

Give this command:  
```ruby pita_run.rb```

The program reports each PDF file it processed and it places the EDI files it generates in the `ediout` folder.  
  
## Import the EDI files into Alma
There are two ways to import the EDI files into Alma.

* In the Alma UI
  * Vendors > All > AMAZ > Click AMAZ > click the EDI Information tab > click the folder icon next to Upload EDI > click on an EDI file > click Add and Execute
* With the Ex Libris Secure FTP Service
  * Put all the files in the `ediout` folder in the `/production/edi/amazedi` folder of the Ex Libris Secure FTP Service
  * Then, start the EDI import job from the AMAZ vendor record in Alma.
  * Vendors > All > AMAZ > Click AMAZ > click the EDI Information tab > click Run Now.
  
## Save the PDF files and the EDI files for future research
Create a new quickshare folder in `J:\QuickShare\dfulmer\pita` and drag the `ediout` and `pdfin` folders in to a new folder named after today's date in the format yyyy-mm-dd.

## Cleanup
Delete all the EDI files  
```rm ediout/*edi```

Delete all the PDF files  