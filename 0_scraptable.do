cap prog drop scraptable
program define scraptable
	syntax anything(name=page equalok everything),[Varnames] [Debug] [Html]
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

		replace page=subinstr(page,"<th","<td",.)
		replace page=subinstr(page,"</th","</td",.)

		gen scratch=page

		replace scratch=subinstr(scratch,"<table","",.)
		gen numTables=(length(page)-length(scratch))/6
		replace scratch=page
		l numTables

		forval t=1/`=numTables[1]' {
			gen start`t'=strpos(scratch,"<table")
			gen end`t'=strpos(scratch,"</table")
			gen table`t'=substr(scratch,start`t',end`t'-start`t'+7)
			gen numRows`t'=(length(table`t')-length(subinstr(table`t',"<tr","",.)))/3
			replace scratch=subinstr(scratch,"<table","",1)
			replace scratch=subinstr(scratch,"</table","",1)
		}


		egen maxRows=rowmax(numRows*)
		set obs `=maxRows[1]'

		forval t=1/`=numTables[1]' {
			replace scratch=table`t'[1]
			gen row`t'=""
			forval i=1/`=numRows`t'[1]' {
				replace row`t'=trim(substr(scratch[1],strpos(scratch[1],"<tr"), strpos(scratch[1],"</tr")-strpos(scratch[1],"<tr")+3)) if _n==`i' 
				replace scratch=subinstr(scratch,row`t'[`i'],"",1) in 1
			}
			replace row`t'=substr(row`t',strpos(row`t',">")+1,.)
		}

		gen temp=.
		forval t=1/`=numTables[1]' {
			replace temp=(length(row`t')-length(subinstr(row`t',"<td","",.)))/3
			egen numCols`t'=max(temp)
		}

		forval t=1/`=numTables[1]' {
			replace scratch=row`t'
			forval i=1/`=numCols`t'[1]' {
				replace scratch=substr(scratch,strpos(scratch,">")+1,.)
				//l scratch
				gen t`t'c`i'=substr(scratch,1,strpos(scratch,"</td")-1)
				replace scratch=substr(scratch,strpos(scratch,"<td"),.)
				if "`html'"=="" striphtml t`t'c`i'
			}
		}

		if "`debug'"=="" keep t*c* numTables numCols*

		if "`varnames'"=="varnames" {
			forval t=1/`=numTables[1]' {
				forval i=1/`=numCols`t'[1]' {
					capture rename t`t'c`i' `=strtoname(t`t'c`i'[1])'
				}
			}
			drop in 1
		}

		if "`debug'"=="" drop numTables numCols*
	}
end
