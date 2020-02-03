cap prog drop scraplist
program define scraplist
	syntax anything(name=page equalok everything), [Debug] [Html]
	di `"Reading `page'"'
	quietly {
		clear	
		set obs 1
		gen page=fileread(`"`page'"')
		if page=="fileread() error 601" {
			di "`page' could not be read"
			error 601
		}
		striphtmlcomments page

		replace page=subinstr(page,"<ul","<ol",.)
		replace page=subinstr(page,"</ul","</ol",.)

		gen scratch=page

		replace scratch=subinstr(scratch,"<ol","",.)
		gen numLists=(length(page)-length(scratch))/3
		replace scratch=page
		l numLists

		forval t=1/`=numLists[1]' {
			gen start`t'=strpos(scratch,"<ol")
			gen end`t'=strpos(scratch,"</ol")
			gen list`t'=substr(scratch,start`t',end`t'-start`t'+7)
			gen numItems`t'=(length(list`t')-length(subinstr(list`t',"<li","",.)))/3
			replace scratch=subinstr(scratch,"<ol","",1)
			replace scratch=subinstr(scratch,"</ol","",1)
		}


		egen maxItems=rowmax(numItems*)
		set obs `=maxItems[1]'

		forval t=1/`=numLists[1]' {
			replace scratch=list`t'[1]
			gen items`t'=""
			forval i=1/`=numItems`t'[1]' {
				replace items`t'=trim(substr(scratch[1],strpos(scratch[1],"<li"), strpos(scratch[1],"</li")-strpos(scratch[1],"<li")+4)) if _n==`i' // & `i'<=numItems`t'
				replace scratch=subinstr(scratch,items`t'[`i'],"",1) in 1
			}
			replace items`t'=trim(substr(items`t',1,strpos(items`t',"</li")-1))
			if "`html'"=="" striphtml items`t'
			else replace items`t'=subinstr(items`t',"<li>","",1)
		}
		

		if "`debug'"=="" {
			keep item*
			rename items* list*
		}
		

	}
end
