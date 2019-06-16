10 GOTO 60
20 POKE 429,lin MOD 256
30 POKE 430,lin\256
40 RESTORE 8400
50 RETURN 'from *** restorelin ***
60 REM That routine enables the program to RESTORE to a variable value.
70 REM It does this by poking the line no. stored in "lin" into line 40.
80 REM
90 REM >>>IMPORTANT<<<
100 REM
110 REM i)  Do not change lines 10-40.
120 REM ii) Do not use the normal RENUM command.
130 REM     instead - press the <ENTER> key on the numeric key pad.
140 REM               Ignore the error message.
150 REM
160 REM NB : the program must be RUN to initialise the <ENTER> key...
170 KEY 139,"POKE 429,0 : POKE 430,0 : RENUM"+CHR$(13)
180 :
190 :
200 REM *************************************************
210 REM *                                               *
220 REM * A D V E N T U R E   K E R N E L   S Y S T E M *
230 REM *                  ( A K S )                    *
235 REM *                                               *
240 REM *************************************************
250 REM *                                               *
260 REM *AKS was written and developed by : Simon Price.*
270 REM *   WITCH HUNT was written jointly by  :        *
275 REM *   Mike Lewis & Simon Price.                   *
280 REM *                                               *
290 REM *   (C) Mike Lewis and Simon Price 1985.        *
300 REM *                                               *
310 REM *************************************************
320 :
330 :
340 MODE 1      'set 40 column screen mode
350 PRINT "Welcome to AKS."
360 PRINT : PRINT "Initialising... please wait"
370 :
380 REM declare all numeric variables as integers
390 DEFINT a-z
400 :
410 REM initialise constants
420 REM
430 lineinc=10  'BASIC line no. increment
440 maxloc=30   'maximum no. locations
450 maxobj=20   'maximum no. objects
460 maxflag=30  'no. of scenario defineable flags
470 maxcount=5  'no. scenario defineable counters
480 maxstack=20 'maximum size of expression evaluator stack
490 true=-1     'boolean values recognised by IF statement
500 false=0
510 linlen=40   'screen width for description output
520 :
530 REM find value of the constant 'datastart'
540 REM ie. the line no. of the first scenario DATA statement
550 ON ERROR GOTO 570 'next but one line
560 GOTO 7680 'an erroneous line immediately preceding first DATA statement
570 IF ERR<>2 THEN ERROR ERR ELSE RESUME 590
580 REM report if not expected error type
590 datastart=ERL+lineinc
600 ON ERROR GOTO 0  'turn error trapping off
610 :
620 :
630 REM initialise variables
640 REM
650 :
660 DIM locline(maxloc) 'line no.s of start of object DATA definitions
670 GOSUB 1080 : REM *initlocations*
680 :
690 DIM objline(maxobj) 'line no.s of start of location DATA definitions
700 DIM objloc(maxobj)  'initial location of objects
710 GOSUB 1320 : REM *initobjects*
720 :
730 DIM eventlin(maxcount) 'event action definition start lines
740 GOSUB 1710 : REM *initevents*
750 :
760 DIM flag(maxflag)      'scenario defined flags
770 DIM worn(noofobjs)     'object worn flags
780 DIM visited(nooflocs)  'location visited by player flags
790 DIM counting(noofcnts) 'countdown timer on flag
800 GOSUB 1920 : REM *resetflags*
810 :
820 DIM count(noofcnts)    'value of countdown timer
830 :
840 DIM stack(maxstack)    'expression evaluation stack
850 stacktop=0
860 :
870 score=0
880 :
890 REM main program body
900 REM
910 CLS
920 eogame=false
930 WHILE NOT(eogame)
940   GOSUB 2090 : REM *describleloc*
950   visited(objloc(0))=true
960   GOSUB 4300 : REM *getcomline*
970   GOSUB 4390 : REM *processcomline*
980   GOSUB 4790 : REM *updatecountdowns*
990 WEND
1000 PRINT
1010 INPUT "Another game ?",res$
1020 IF LOWER$(LEFT$(res$+"y",1))="y" THEN RUN
1030 GOTO 1030 'hang machine up
1040 :
1050 :
1060 REM *** initlocations ***
1070 REM
1080 lin=datastart
1090 loc=0
1100 type$="?" 'dummy value to force at least one iteration of WHILE
1110 WHILE INSTR("OEF",type$)=0
1120   GOSUB 20 : REM *restorelin*
1130   READ type$
1140   IF type$="L" THEN GOSUB 1230 : REM *initloc*
1150   lin=lin+lineinc
1160 WEND
1170 nooflocs=loc-1
1180 RETURN
1190 :
1200 :
1210 REM *** initloc ***  
1220 REM
1230 READ defloc
1240 IF loc<>defloc THEN PRINT"loc out of sequence AT LINE ";lin : END
1250 locline(loc)=lin+lineinc
1260 loc=loc+1
1270 RETURN
1280 :
1290 :
1300 REM *** initobjects ***
1310 REM
1320 obj=0
1330 lin=lin-lineinc
1340 WHILE INSTR("EF",type$)=0
1350   IF type$="O" THEN GOSUB 1460 : REM *initobj*
1360   lin=lin+lineinc
1370   GOSUB 20 : REM *restorelin*   
1380   READ type$
1390 WEND
1400 noofobjs=obj-1
1410 RETURN
1420 :
1430 :
1440 REM *** initobj ***
1450 REM
1460 READ defobj
1470 IF obj<>defobj THEN PRINT"obj out of sequence AT LINE ";lin : END
1480 objline(obj)=lin+lineinc
1490 type$="?" 'dummy value
1500 WHILE INSTR("OEF",type$)=0
1510   lin=lin+lineinc
1520   GOSUB 20 : REM *restorelin*
1530   READ type$
1540   IF type$="P" THEN GOSUB 1630 : REM *initobjloc*
1550 WEND
1560 lin=lin-lineinc 'adjust to suit *initobjects*
1570 obj=obj+1
1580 RETURN
1590 :
1600 :
1610 REM *** initobjloc ***
1620 REM
1630 READ loc
1640 IF loc<-1 OR loc>nooflocs THEN PRINT"obj loc out of range AT LINE ";lin : END
1650 objloc(obj)=loc
1660 RETURN
1670 :
1680 :
1690 REM *** initevents ***
1700 REM
1710 noofcnts=0
1720 WHILE type$<>"F"
1730   GOSUB 20 : REM *restorelin*
1740   READ type$
1750   IF type$="E" THEN GOSUB 1830 : REM *initeventlin*
1760   lin=lin+lineinc
1770 WEND
1780 RETURN
1790 :
1800 :
1810 REM *** initeventlin ***
1820 REM
1830 READ cnt
1840 IF cnt<>noofcnts THEN PRINT"event out of sequence AT LINE ";lin
1850 eventlin(cnt)=lin+lineinc
1860 noofcnts=noofcnts+1
1870 RETURN
1880 :
1890 :
1900 REM *** resetflags ***
1910 REM
1920 FOR i=0 TO maxflag
1930   flag(i)=false
1940 NEXT
1950 FOR i=0 TO noofobjs
1960   worn(i)=false
1970 NEXT
1980 FOR i=0 TO nooflocs
1990   visited(i)=false
2000 NEXT
2010 FOR i=0 TO noofcnts
2020   counting(i)=false
2030 NEXT
2040 RETURN
2050 :
2060 :
2070 REM *** describeloc ***
2080 REM
2090 PRINT : PRINT : PRINT STRING$(40,"-")
2100 lin=locline(objloc(0)) : GOSUB 2220 : REM *describleln*
2110 loc=objloc(0) : GOSUB 2610 : REM *isobjatloc*
2120 IF NOT(res) THEN RETURN 'quit
2130 PRINT"There is/are : "
2140 FOR obj=1 TO noofobjs
2150   IF objloc(obj)=objloc(0) THEN PRINT"   "; : lin=objline(obj) : GOSUB 2220 : REM *describeln*
2160 NEXT
2170 RETURN
2180 :
2190 :
2200 REM *** describeln ***
2210 REM
2220 linefeed=true
2230 GOTO 2270
2240 REM *** describe ***
2250 REM
2260 linefeed=false
2270 type$="?" 'dummy value
2280 WHILE INSTR("LOEF",type$)=0
2290   GOSUB 20 : REM *restoreln*
2300   READ type$
2310   IF type$<>"D" THEN 2340 'go try next DATA line
2320   GOSUB 2700 : REM *evalnext*
2330   IF res THEN READ descr$ : GOSUB 2410 : REM *printdescr*
2340   lin=lin+lineinc
2350 WEND
2360 RETURN
2370 :
2380 :
2390 REM *** printdescr ***
2400 REM
2410 WHILE LEN(descr$) > linlen-POS(#0)+1
2420   rlim=linlen-POS(#0)+1        'right hand side of screen
2430   rhs=rlim+1                   '1 char beyond screen right
2440   WHILE MID$(descr$,rhs,1)<>" "
2450     rhs=rhs-1   'skip backwards over rightmost word on line
2460   WEND
2470   rhs=rhs-1
2480   PRINT LEFT$(descr$,rhs);
2490   IF POS(#0)>1 THEN PRINT     'start new line if not at start of one
2500   descr$=RIGHT$(descr$,LEN(descr$)-rhs)
2510   WHILE LEFT$(descr$,1)=" "     'skip over leading spaces
2520     descr$=RIGHT$(descr$,LEN(descr$)-1)
2530   WEND
2540 WEND
2550 PRINT descr$;
2560 IF linefeed THEN PRINT
2570 RETURN
2580 :
2590 REM *** isobjatloc ***
2600 REM
2610 res=false
2620 FOR obj=1 TO noofobjs
2630  IF objloc(obj)=loc THEN res=true
2640 NEXT
2650 RETURN
2660 :
2670 :
2680 REM *** evalnext ***
2690 REM
2700 READ expr$
2710 GOSUB 2770 : REM *evalthis*
2720 RETURN
2730 :
2740 :
2750 REM *** evalthis ***
2760 REM
2770 char$=LEFT$(expr$,1)
2780 IF char$<>"*" THEN PRINT"EXPR expected AT LINE ";lin : END
2790 IF LEN(expr$)=1 THEN res=true : RETURN 'quit
2800 expr$=RIGHT$(expr$,LEN(expr$)-1)
2810 GOSUB 2880 : REM *converttoRP*
2820 GOSUB 3780 : REM *evaluateRP*
2830 RETURN 'res is either true/false
2840 :
2850 :
2860 REM *** converttoRP ***
2870 REM
2880 revpol$=""
2890 dat=ASC("(") : GOSUB 4120 : REM *stackdat*
2900 WHILE LEN(expr$)<>0
2910   GOSUB 3050 : REM *getlex*
2920   IF INSTR("tf",dat$)<>0 THEN revpol$=revpol$+dat$ : GOTO 2980 'next lex
2930   REM dat$ is an operator
2940   dat=ASC(dat$)
2950   IF dat$="(" THEN GOSUB 4120 : REM *stackdat*
2960   IF dat$=")" THEN GOSUB 3430 : REM *closepar*
2970   IF INSTR("()",dat$)=0 THEN GOSUB 3540 : REM *comparepriority*
2980 WEND
2990 GOSUB 3430 : REM *closepar*
3000 RETURN
3010 :
3020 :
3030 REM *** getlex ***
3040 REM
3050 dat$=LEFT$(expr$,1)
3060 expr$=RIGHT$(expr$,LEN(expr$)-1)
3070 used=false
3080 IF INSTR("FVWECLO",dat$)<>0 THEN used=true : GOSUB 3150 : REM *evalflag*
3090 IF NOT(used) AND INSTR("()/.-",dat$)=0 THEN PRINT"invalid expr AT LINE ";lin : END
3100 RETURN
3110 :
3120 :
3130 REM *** evalflag ***
3140 REM
3150 num=0
3160 isdigit=true : gotnum=false
3170 WHILE isdigit AND LEN(expr$)<>0
3180   char$=LEFT$(expr$,1)
3190   chval=ASC(char$)-ASC("0") 'convert to digit
3200   IF chval<0 OR chval>9 THEN isdigit=false ELSE expr$=RIGHT$(expr$,LEN(expr$)-1) : num=num*10+chval : gotnum=true
3210 WEND
3220 IF NOT(gotnum) THEN PRINT"flag no. missing AT LINE ";lin : END
3230 GOSUB 3300 : REM *setbool*
3240 IF bool THEN dat$="t" ELSE dat$="f"
3250 RETURN
3260 :
3270 :
3280 REM *** setbool ***
3290 REM
3300 bool=false
3310 ON INSTR("FVWCLO",dat$) GOTO 3320,3330,3340,3350,3360,3370
3320 bool=flag(num) : RETURN      'F-flag
3330 bool=visited(num) : RETURN   'V-flag
3340 bool=worn(num) : RETURN      'W-flag
3350 IF objloc(num)=0 THEN bool=true : RETURN ELSE RETURN          'C-flag
3360 IF objloc(0)=num THEN bool=true : RETURN ELSE RETURN          'L-flag
3370 IF objloc(num)=objloc(0) THEN bool=true : RETURN ELSE RETURN  'O-flag
3380 RETURN
3390 :
3400 :
3410 REM *** closepar ***
3420 REM
3430 releasing=true
3440 WHILE releasing
3450   GOSUB 4200 : REM *unstackdat*
3460   op$=CHR$(dat)
3470   IF op$="(" THEN releasing=false ELSE revpol$=revpol$+op$
3480 WEND
3490 RETURN
3500 :
3510 :
3520 REM *** comparepriority ***
3530 REM
3540 newop=dat 'save new operator code
3550 GOSUB 3720 : REM *priority*
3560 newpri=oppri
3570 releasing=true
3580 WHILE releasing AND stacktop<>0
3590   GOSUB 4200 : REM *unstackdat*
3600   GOSUB 3720 : REM *priority*
3610   IF newpri<oppri THEN revpol$=revpol$+CHR$(dat) : GOTO 3650 'next
3620   releasing=false
3630   GOSUB 4120 : REM *stackdat*
3640   dat=newop
3650 WEND
3660 GOSUB 4120 : REM *stackdat*
3670 RETURN
3680 :
3690 :
3700 REM *** priority ***
3710 REM
3720 oppri=INSTR("(/.-",CHR$(dat))
3730 RETURN
3740 :
3750 :
3760 REM *** evaluateRP ***
3770 REM
3780 WHILE LEN(revpol$)>0
3790   dat$=LEFT$(revpol$,1)
3800   revpol$=RIGHT$(revpol$,LEN(revpol$)-1)
3810   IF INSTR("tf",dat$)<>0 THEN dat=ASC(dat$) : GOSUB 4120 : REM *stackdat*
3820   IF INSTR("tf",dat$)=0 THEN GOSUB 3940 : REM *evalop*
3830 WEND
3840 GOSUB 4180 : REM *unstackdat*
3850 IF dat=ASC("t") THEN dat=true
3860 IF dat=ASC("f") THEN dat=false
3870 res=dat 'dat may already have been boolean (0,-1)
3880 IF stacktop<>0 THEN PRINT "Invalid expr AT LINE ";lin : END
3890 RETURN
3900 :
3910 :
3920 REM *** evalop ***
3930 REM
3940 GOSUB 4180 : REM *unstackdat*
3950 IF dat=ASC("t") THEN op1=true ELSE op1=false
3960 IF dat$<>"-" THEN 4000 'not a unary operator
3970 dat=NOT(op1)
3980 GOTO 4050 'store result
3990 REM binary operators
4000 GOSUB 4180 : REM *unstackdat*
4010 IF dat=ASC("t") THEN op2=true ELSE op2=false
4020 IF dat$="." THEN dat=op1 AND op2
4030 IF dat$="/" THEN dat=op1 OR op2
4040 REM store result
4050 IF dat THEN dat=ASC("t") ELSE dat=ASC("f")
4060 GOSUB 4120 : REM *stackdat*
4070 RETURN
4080 :
4090 :
4100 REM *** stackdat*
4110 REM
4120 stack(stacktop)=dat
4130 stacktop=stacktop+1
4140 IF stacktop>maxstack THEN PRINT"expr too large AT LINE ";lin : END
4150 RETURN
4160 :
4170 :
4180 REM *** unstackdat ***
4190 REM
4200 stacktop=stacktop-1
4210 IF stacktop<0 THEN PRINT"Incomplete expr AT LINE ";lin : END
4220 dat=stack(stacktop)
4230 RETURN
4240 :
4250 :
4260 :
4270 :
4280 REM *** getcomline ***
4290 REM
4300 PRINT : INPUT "What now ? ",in$
4310 PRINT
4320 comline$=LOWER$(in$)
4330 RETURN
4340 :
4350 :
4360 REM *** processconline ***
4370 REM
4380 REM remember to ensure that the strings come before substrings - eg. "take off" must be defined before "take" or it would never be reached.
4390 trig=false
4400 lin=locline(objloc(0)) : GOSUB 4480 : REM *triggers*
4410 IF NOT(trig) THEN lin=locline(0) : GOSUB 4480 : REM *triggers*
4420 IF NOT(trig) THEN PRINT "Sorry I do not understand that." ELSE GOSUB 5430 : REM *actions*
4430 RETURN
4440 :
4450 :
4460 REM *** triggers ***
4470 REM
4480 type$="?" 'dummy value
4490 WHILE NOT(trig) AND INSTR("LOEF",type$)=0
4500   GOSUB 20 : REM *restorelin*
4510   READ type$
4520   IF type$="T" THEN GOSUB 4600 : REM *triggertest*
4530   lin=lin+lineinc
4540 WEND
4550 RETURN
4560 :
4570 :
4580 REM *** triggertest ***
4590 REM
4600 match=false
4610 trigsleft=true
4620 comlen=LEN(comline$) : xcomline$=" "+comline$+" "   'constants within loop
4630 WHILE NOT(match) AND trigsleft
4640   READ trig$
4650   IF LEFT$(trig$,1)="*" THEN trigsleft=false : GOTO 4670 'quit loop
4660   IF comlen >= LEN(trig$) THEN IF INSTR(xcomline$," "+trig$+" ")<>0 THEN match=true
4670 WEND
4680 WHILE trigsleft
4690   READ trig$    'consume remaining triggers upto expr
4700   IF LEFT$(trig$,1)="*" THEN trigsleft=false
4710 WEND
4720 IF NOT(match) THEN res=false ELSE expr$=trig$ : GOSUB 2770 : REM *evalthis*
4730 trig=res
4740 RETURN
4750 :
4760 :
4770 REM *** updatecountdowns ***
4780 REM
4790 FOR i=0 TO noofcnts
4800   IF NOT(counting(i)) THEN 4860 'test next one
4810   count(i)=count(i)-1
4820   IF count(i)>0 THEN 4860 'no event yet
4830   counting(i)=false
4840   lin=eventlin(i) : GOSUB 20 : REM *restorelin*
4850   GOSUB 5430 : REM *actions*
4860 NEXT
4870 RETURN
4880 :
4890 :
4900 :
4910 :
4920 REM *** assignobj ***
4930 REM
4940 obj=1 'start with first real object (as obj0 is player)
4950 trig=false
4960 WHILE NOT(trig) AND obj<=noofobjs
4970   lin=objline(obj)
4980   GOSUB 5100 : REM *namesearch*
4990   obj=obj+1
5000 WEND
5010 IF NOT(trig) THEN PRINT "You can't do that." : RETURN
5020 obj=obj-1
5030 GOSUB 5220 : REM *suitability*
5040 IF NOT(res) THEN trig=false : PRINT"That is not possible."
5050 RETURN
5060 :
5070 :
5080 REM *** namesearch ***
5090 REM
5100 type$="?" 'dummy value
5110 WHILE NOT(trig) AND INSTR("OEF",type$)=0
5120   GOSUB 20 : REM *restorelin*
5130   READ type$
5140   IF type$="N" THEN GOSUB 4600 : REM *triggertest*
5150   lin=lin+lineinc
5160 WEND
5170 RETURN
5180 :
5190 :
5200 REM *** suitability ***
5210 REM
5220 lin=objline(obj)
5230 res=false
5240 type$="?" 'dummy value
5250 WHILE NOT(res) AND INSTR("OEF",type$)=0
5260   GOSUB 20 : REM *restorelin*
5270   READ type$
5280   IF type$="S" THEN GOSUB 5360 : REM *suittest*
5290   lin=lin+lineinc
5300 WEND
5310 RETURN
5320 :
5330 :
5340 REM *** suittest ***
5350 REM
5360 READ suit$
5370 IF suit$=actsuit$ THEN GOSUB 2700 : REM *evalnext*
5380 RETURN
5390 :
5400 :
5410 REM *** actions ***
5420 REM
5430 actline=lin  'maintain a seperate lin for this routine
5440 acttype$="?" 'dummy value
5450 WHILE INSTR("TLOEF",acttype$)=0
5460   lin=actline : GOSUB 20 : REM *restorelin*
5470   READ acttype$
5480   actline=actline+lineinc
5490   IF acttype$<>"A" THEN GOTO 5700 'no more actions for this trigger
5500   READ act$
5510   IF act$="SC" THEN GOSUB 5760 : REM *SCore*
5520   IF act$="IN" THEN GOSUB 5820 : REM *INventory*
5530   IF act$="QU" THEN GOSUB 5960 : REM *QUit*
5540   IF act$="IS" THEN GOSUB 6020 : REM *IncScore*
5550   IF act$="AF" THEN GOSUB 6090 : REM *AssignFlag*
5560   IF act$="PR" THEN GOSUB 6160 : REM *PRint*
5570   IF act$="GO" THEN GOSUB 6320 : REM *GO*
5580   IF act$="MO" THEN GOSUB 6250 : REM *MoveObj*
5590   IF act$="GE" THEN GOSUB 6580 : REM *GEt*
5600   IF act$="DR" THEN GOSUB 6660 : REM *DRop*
5610   IF act$="PO" THEN GOSUB 6740 : REM *PutOn*
5620   IF act$="TO" THEN GOSUB 6820 : REM *TakeOff*
5630   IF act$="EX" THEN GOSUB 6900 : REM *EXamine*
5640   IF act$="IC" THEN GOSUB 6990 : REM *InitCounter*
5650   IF act$="HC" THEN GOSUB 7070 : REM *HaltCounter*
5660   IF act$="ZI" THEN GOSUB 7140 : REM *ZapIn*
5670   IF act$="ZO" THEN GOSUB 7220 : REM *ZapOut*
5680   IF act$="LO" THEN GOSUB 7300 : REM *LOad*
5690   IF act$="SA" THEN GOSUB 7440 : REM *SAve*
5700 WEND
5710 RETURN
5720 :
5730 :
5740 REM *** SCore ***
5750 REM
5760 PRINT "You have scored ";score
5770 RETURN
5780 :
5790 :
5800 REM *** INventory ***
5810 REM
5820 loc=0 : GOSUB 2610 : REM *isobjatloc*
5830 IF NOT(res) THEN PRINT "You are not carrying anything." : RETURN 'quit
5840 PRINT"You are carrying : "
5850 FOR obj=1 TO noofobjs
5860   IF objloc(obj)<>0 THEN GOTO 5900 'this obj not carried
5870   PRINT "   ";
5880   lin=objline(obj) : GOSUB 2260 : REM *describe*
5890   IF worn(obj) THEN PRINT " (worn)" ELSE PRINT
5900 NEXT
5910 RETURN
5920 :
5940 REM *** QUit ***
5950 REM
5960 eogame=true
5970 RETURN
5980 :
5990 :
6000 REM *** IncScore ***
6010 REM
6020 READ inc
6030 score=score+inc
6040 RETURN
6050 :
6060 :
6070 REM *** AssignFlag ***
6080 REM
6090 READ flagnum,bool$
6100 IF bool$="T" THEN flag(flagnum)=true ELSE flag(flagnum)=false
6110 RETURN
6120 :
6130 :
6140 REM *** PRint ***
6150 REM
6160 READ descr$
6170 linefeed=true
6180 GOSUB 2410 : REM *printdescr*
6190 PRINT
6200 RETURN
6210 :
6220 :
6230 REM *** MOve ***
6240 REM
6250 READ obj,loc
6260 objloc(obj)=loc
6270 worn(obj)=false
6280 RETURN
6290 :
6300 REM *** GO ***
6310 REM
6320 READ dir$
6330 lin=locline(objloc(0))
6340 match=false
6350 type$="?" 'dummy value
6360 WHILE NOT(match) AND INSTR("LOEF",type$)=0
6370   GOSUB 20 : REM *restorelin*
6380   READ type$
6390   IF type$="C" THEN GOSUB 6480 : REM *GO2*
6400   lin=lin+lineinc
6410 WEND
6420 IF NOT(match) OR (match AND NOT(res)) THEN PRINT"You can not go that way."
6430 RETURN
6440 :
6450 :
6460 REM *** GO2 ***
6470 REM
6480 READ defdir$
6490 IF dir$<>defdir$ THEN RETURN 'quit
6500 match=true
6510 GOSUB 2700 : REM *evalnext*
6520 IF res THEN READ objloc(0)
6530 RETURN
6540 :
6550 :
6560 REM *** GEt ***
6570 REM
6580 actsuit$="GE" : GOSUB 4940 : REM *assignobj*
6590 IF NOT(trig) THEN RETURN 'quit
6600 IF objloc(obj)=objloc(0) THEN objloc(obj)=0 : PRINT "Taken." ELSE PRINT"You can not see it here."
6610 RETURN
6620 :
6630 :
6640 REM *** DRop ***
6650 REM
6660 actsuit$="DR" : GOSUB 4940 : REM *assignobj*
6670 IF NOT(trig) THEN RETURN 'quit
6680 IF objloc(obj)=0 THEN objloc(obj)=objloc(0) : worn(obj)=false : PRINT"Dropped." ELSE PRINT"You do not have it."
6690 RETURN
6700 :
6710 :
6720 REM *** PutOn ***
6730 REM
6740 actsuit$="PO" : GOSUB 4940 : REM *assingobj*
6750 IF NOT(trig) THEN RETURN 'quit
6760 IF objloc(obj)=0 THEN worn(obj)=true : PRINT"Worn." ELSE PRINT"You do not have it."
6770 RETURN
6780 :
6790 :
6800 REM *** TakeOff ***
6810 REM
6820 actsuit$="TO" : GOSUB 4940 : REM *assignobj*
6830 IF NOT(trig) THEN RETURN 'quit
6840 IF worn(obj) THEN worn(obj)=false : PRINT"Removed." ELSE PRINT"You are not wearing it."
6850 RETURN
6860 :
6870 :
6880 REM *** EXamine ***
6890 REM
6900 actsuit$="EX" : GOSUB 4940 : REM *assignobj*
6910 IF NOT(trig) THEN RETURN 'quit
6920 IF NOT(objloc(obj)=0 OR objloc(obj)=objloc(0)) THEN PRINT"You see nothing special." ELSE READ descr$ : linefeed=true : GOSUB 2410 : REM *printdescr*
6930 lin=objline(obj)
6940 RETURN
6950 :
6960 :
6970 REM *** InitCounter*
6980 REM
6990 READ cnum,cval
7000 count(cnum)=cval
7010 counting(cnum)=true
7020 RETURN
7030 :
7040 :
7050 REM *** HaltCounter ***
7060 REM
7070 READ cnum
7080 counting(cnum)=false
7090 RETURN
7100 :
7110 :
7120 REM *** ZapIn ***
7130 REM
7140 READ obj
7150 objloc(obj)=objloc(0)   'move object to current location
7160 worn(obj)=false
7170 RETURN
7180 :
7190 :
7200 REM *** ZapOut ***
7210 REM
7220 READ obj
7230 objloc(obj)=-1          'set object location to nowhere
7240 worn(obj)=false
7250 RETURN
7260 :
7270 :
7280 READ *** LOAD ***
7290 REM
7300 GOSUB 7570 : REM *getfname*
7310 SPEED WRITE 1
7320 OPENIN file$
7330 INPUT #9,score,nooflocs,noofobjs,maxflag,noofcnts
7340 FOR l=0 TO nooflocs : INPUT #9,visited(l) : NEXT l
7350 FOR l=0 TO noofobjs : INPUT #9,objloc(l),worn(l) : NEXT l
7360 FOR l=0 TO maxflag : INPUT #9,flag(l) : NEXT l
7370 FOR l=0 TO noofcnts : INPUT #9,count(l),counting(l) : NEXT l
7380 CLOSEIN
7390 RETURN
7400 :
7410 :
7420 REM *** SAve ***
7430 REM
7440 GOSUB 7570 : REM *getfname*
7450 OPENOUT file$
7460 WRITE #9,score,nooflocs,noofobjs,maxflag,noofcnts
7470 FOR l=0 TO nooflocs : WRITE #9,visited(l) : NEXT l
7480 FOR l=0 TO noofobjs : WRITE #9,objloc(l),worn(l) : NEXT l
7490 FOR l=0 TO maxflag : WRITE #9,flag(l) : NEXT l
7500 FOR l=0 TO noofcnts : WRITE #9,count(l),counting(l) : NEXT l
7510 CLOSEOUT
7520 RETURN
7530 :
7540 :
7550 REM *** getfname ***
7560 REM
7570 IF LEN(comline$)<6 THEN file$="SAVEFILE" : RETURN 'default name
7580 comline$=MID$(comline$+STRING$(16," "),6,8)       'extract filename
7590 file$=""
7600 FOR l=1 TO LEN(comline$)   'remove any quote marks
7610   IF MID$(comline$,1,1)<>CHR$(34) THEN file$=file$+MID$(comline$,1,1)
7620 NEXT l
7630 RETURN
7640 :
7650 :
7660 :
7670 :
7680 THIS LINE GENERATES AN ERROR
7690 DATA L,0
7700 DATA  T,n,north,*F4
7710 DATA   A,GO,N
7720 DATA   A,ZI,12
7730 DATA  T,n,north,*
7740 DATA   A,GO,N
7750 DATA  T,e,east,*F4
7760 DATA   A,GO,E
7770 DATA   A,ZI,12
7780 DATA  T,e,east,*
7790 DATA   A,GO,E
7800 DATA  T,s,south,*F4
7810 DATA   A,GO,S
7820 DATA   A,ZI,12
7830 DATA  T,s,south,*
7840 DATA   A,GO,S
7850 DATA  T,w,west,*F4
7860 DATA   A,GO,W
7870 DATA   A,ZI,12
7880 DATA  T,w,west,*
7890 DATA   A,GO,W
7900 DATA  T,u,up,*F4
7910 DATA   A,GO,U
7920 DATA   A,ZI,12
7930 DATA  T,u,up,*
7940 DATA   A,GO,U
7950 DATA  T,d,down,*F4
7960 DATA   A,GO,D
7970 DATA   A,ZI,12
7980 DATA  T,d,down,*
7990 DATA   A,GO,D
8000 DATA  T,wear,put on,*
8010 DATA   A,PO
8020 DATA  T,remove,take off,*
8030 DATA   A,TO
8040 DATA  T,get,take,pick up,catch,*
8050 DATA   A,GE
8060 DATA  T,drop,put,throw,release,*
8070 DATA   A,DR
8080 DATA  T,ex,exam,examine,look at,*
8090 DATA   A,EX
8100 DATA  T,i,inv,inventory,*
8110 DATA   A,IN
8120 DATA  T,score,*
8130 DATA   A,SC
8140 DATA  T,load,*
8150 DATA   A,LO
8160 DATA   A,IS,-1
8170 DATA  T,save,*
8180 DATA   A,SA
8190 DATA  T,eat bread,eat loaf,*C5
8200 DATA   A,PR,yummy yummy!
8210 DATA   A,ZO,5
8220 DATA  T,eat cheese,*C4
8230 DATA   A,PR,Far too mouldy!
8240 DATA  T,eat,*
8250 DATA   A,PR,No thanks.
8260 DATA  T,feed cat,drop mouse,release mouse,*C6.O12
8270 DATA   A,PR,The cat kaes both mouse and cheese and then runs off.
8280 DATA   A,IS,10
8290 DATA   A,AF,4,F
8300 DATA   A,ZO,6
8310 DATA   A,ZO,12
8320 DATA   A,HC,0
8330 DATA  T,hit,kill,attack,*
8340 DATA   A,PR,Sorry. No violence is allowed in this game.
8350 DATA  T,show,give,accuse,feed,*
8360 DATA   A,PR,Not interested.
8370 DATA  T,quit,*
8380 DATA   A,SC
8390 DATA   A,QU
8400 DATA L,1
8410 DATA  D,*,In the middle of the village green.
8420 DATA  D,*-V1,Beyond the north end of the green you can see your home - the mill. To east is the inn. The church where all this trouble began is to the south. You can hear the goats making goaty noises to the west.
8430 DATA  T,inn,*-F6
8440 DATA   A,GO,E
8450 DATA  T,e,east,inn,*F6
8460 DATA   A,PR,The innkeeper refuses to let you enter the inn.
8470 DATA  T,e,east,inn,*-F11
8480 DATA   A,GO,E
8490 DATA   A,AF,11,T
8500 DATA   A,IC,1,100
8510 DATA  T,n,north,*-F11
8520 DATA   A,GO,N
8530 DATA   A,AF,11,T
8540 DATA   A,IC,1,100
8550 DATA  T,w,west,*-F11
8560 DATA   A,GO,W
8570 DATA   A,AF,11,T
8580 DATA   A,IC,1,100
8590 DATA  T,s,south,*-F11
8600 DATA   A,GO,S
8610 DATA   A,AF,11,T
8620 DATA   A,IC,1,100
8630 DATA  C,N,*,4
8640 DATA  C,S,*,6
8650 DATA  C,E,*,2
8660 DATA  C,W,*,5
8670 DATA L,2
8680 DATA  D,*,The bar in the Melbourne Inn.
8690 DATA  D,*F5,Some fool has balanced a pointed hat on top of the kitchen door!
8700 DATA  D,*-V2,The inn is closed at the moment due to the unexplained spoiling of the ale. The kitchen door sits slightly ajar at the east end of the room.
8710 DATA  T,balance hat,put hat,place hat,*C1
8720 DATA   A,PR,You manage to balance the hat on top of the kitchen door.
8730 DATA   A,AF,5,T
8740 DATA   A,ZO,1
8750 DATA  T,e,east,kitchen,*F5
8760 DATA   A,PR,The hat falls to the floor.
8770 DATA   A,ZI,1
8780 DATA   A,AF,5,F
8790 DATA   A,GO,E
8800 DATA  T,get hat,*
8810 DATA   A,ZI,1
8820 DATA   A,AF,5,F
8830 DATA   A,GE
8840 DATA  T,call,shout,*-F5
8850 DATA   A,PR,"The innkeeper comes into the room, but seeing you he crosses himself and dashes back into the kitchen."
8860 DATA  T,call,shout,*F5
8870 DATA   A,PR,The innkeeper pushes the kitchen door open and steps into the room.
8880 DATA   A,PR,PLOP! The hat lands on his head. It looks like a thimble on a giants head. He throws you and your hat out of the inn.
8890 DATA   A,IS,10
8900 DATA   A,GO,W
8910 DATA   A,ZI,1
8920 DATA   A,AF,5,F
8930 DATA   A,AF,6,T
8940 DATA  T,leave,out,*
8950 DATA   A,GO,W
8960 DATA  C,E,*,3
8970 DATA  C,W,*,1
8980 DATA L,3
8990 DATA  D,*,Kitchen in the Melbourne.
9000 DATA  D,*-V3,It seems surprisingly empty, Perhaps the innkeeper is a little short of money at the moment.
9010 DATA  T,steal cheese,*
9020 DATA   A,GE
9030 DATA  T,cheese,*O4
9040 DATA   A,PR,GET OFF MY CHEESE! What do you mean openly trying to take my food!
9050 DATA  T,give,*C10.O5
9060 DATA   A,A,PR,The innkeeper says "Oh goody goody. I can bake some more loaves now." and grabs your sack of flour. "You can have this loaf."
9070 DATA   A,MO,5,0
9080 DATA   A,ZO,10
9090 DATA  T,loaf,bread,*O5
9100 DATA   A,PR,GET OFF MY BREAD! What do you mean trying to take my last loaf!
9110 DATA  T,leave,out,bar,*
9120 DATA   A,GO,W
9130 DATA  C,W,*,2
9140 DATA L,4
9150 DATA  D,*,At the north end of the village green.
9160 DATA  D,*-V4,You remember coming here in the past to throw rotten food (and the odd brick) at people in the stocks. This is where they always burnt witches. You remember throwing on wood... Those were good times.
9170 DATA  T,put hat,place hat,try hat,*C1.F10
9180 DATA   A,PR,It fits!
9190 DATA   A,PR,A crowd of villagers gather. "The blacksmith is the witch!" screams the priest. "Burn him! Burn him! Burn him!". And they do. Everyone has a real good time... roasting chestnuts and potatoes in the fire. You have cleared yourself.
9200 DATA   A,IS,20
9210 DATA   A,SC
9220 DATA   A,QU
9230 DATA  T,road,*
9240 DATA   A,GO,E
9250 DATA  C,S,*,1
9260 DATA  C,E,*,14
9270 DATA L,5
9280 DATA  D,*,An area of grazing land.
9290 DATA  T,feed,cheese,*C4
9300 DATA   A,PR,A goat snatches your cheese and eats it.
9310 DATA   A,ZO,4
9320 DATA  T,feed,bread,loaf,*C5
9330 DATA   A,PR,A goat snatches your bread and eats it.
9340 DATA   A,ZO,5
9350 DATA  C,E,*,1
9360 DATA L,6
9370 DATA  D,*,At the southern end of the village green.
9380 DATA  D,*-V6,A foul odour drifts from the direction of the meadow at the west of the green.
9390 DATA  T,meadow,*
9400 DATA   A,GO,W
9410 DATA  T,church,*
9420 DATA   A,GO,S
9430 DATA  C,W,*,8
9440 DATA  C,N,*,1
9450 DATA  C,S,*,10
9460 DATA L,7
9470 DATA  D,*,At the edge of the village pond.
9480 DATA  D,*-V7,The pond is stagnant and smells foul.
9490 DATA  T,put toad,drop toad,throw toad,release toad,*C2.-F3
9500 DATA   A,DR
9510 DATA   A,PR,Splash...! The toad turns into a small boy. "Where am I? What happened?" he mutters as he climbs out of the pond. "Last thing I remember I was strolling in the woods!"
9520 DATA   A,AF,3,T
9530 DATA   A,IS,5
9540 DATA  T,feed duck,feed ducks,*C5
9550 DATA   A,PR,The ducks gobble up the bread and leave. There was something hidden in their nest.
9560 DATA   A,ZO,3
9570 DATA   A,ZO,5
9580 DATA   A,ZI,14
9590 DATA   A,IS,5
9600 DATA  T,fill,water,pond,*
9610 DATA   A,PR,It is impossible to get at the water.
9620 DATA  C,S,*,8
9630 DATA L,8
9640 DATA  D,*V8,In the meadow.
9650 DATA  D,*-V8,In the middle of the meadow. To the north the ground becomes marshy. At the western end of the meadow you can see a wooden building.
9660 DATA  C,N,*,7
9670 DATA  C,W,*,9
9680 DATA  C,E,*,6
9690 DATA L,9
9700 DATA  D,*,At the blacksmith's forge.
9710 DATA  D,*-V9,You remember coming here often in the past. The blacksmith always repairs everyones tools. He is a pretty good all round handyman.
9720 DATA  T,show gold,give gold,show coins,give coins,accuse,*C14
9730 DATA   A,PR,The blacksmith bursts into tears. "Alright. I confess - I stole the woodcutter's gold." he blurts out.
9740 DATA   A,PR,A crowd of villagers rush up and drag the pleading blacksmith away.
9750 DATA   A,IS,20
9760 DATA   A,AF,10,T
9770 DATA   A,MO,16,4
9780 DATA  T,show,give,accuse,forge,anvil,*
9790 DATA   A,PR,He shouts "Be off with you! Little witch."
9800 DATA  C,E,*,8
9810 DATA L,10
9820 DATA  D,*,In the church nave.
9830 DATA  D,*-V10,The secret entrance to the crypt you found lies open. High above you is the belfry balcony. The front door is to the north. In the south wall is a small door.
9840 DATA  T,hat,*F2.O9
9850 DATA   A,PR,Tug...
9860 DATA   A,ZI,1
9870 DATA   A,AF,1,F
9880 DATA   A,ZO,9
9890 DATA   A,GE
9900 DATA   A,PR,The priest storms off.
9910 DATA  T,crypt,*
9920 DATA   A,GO,D
9930 DATA  T,belfry,*
9940 DATA   A,GO,U
9950 DATA  C,N,*,6
9960 DATA  C,S,*,13
9970 DATA  C,D,*,12
9980 DATA  C,U,*,11
9990 DATA L,11
10000 DATA  D,*,In the belfry.
10010 DATA  D,*-V11,Far below you can see the church nave.
10020 DATA  T,ring bell,*-(F1/F2)
10030 DATA   A,PR,The bell tolls and nearly deafens you.
10040 DATA   A,MO,9,10
10050 DATA   A,PR,You see the priest run into the church directly below you.
10060 DATA   A,AF,1,T
10070 DATA  T,ring bell,*
10080 DATA   A,PR,Ding dong...!
10090 DATA  T,drop hat,throw hat,*C1.F1
10100 DATA   A,PR,The hat drops from the belfry and lands over the priest's head."
10110 DATA   A,IS,10
10120 DATA   A,AF,2,T
10130 DATA   A,ZO,1 
10140 DATA  T,drop hat,throw hat,*C1.-F1
10150 DATA   A,PR,Weeee.... it gall from the belfrey.
10160 DATA   A,MO,1,10
10170 DATA  T,nave,leave,*
10180 DATA   A,GO,D
10190 DATA  C,D,*,10
10200 DATA L,12
10210 DATA  D,*,In the secret crypt.
10220 DATA  D,*-V12,The air is icy cold. The floor is intricately carved with strange markings. On the wall are lit torches.
10230 DATA  T,torches,torch,wall,walls,*
10240 DATA   A,PR,A couple of torches are firmly attached to the wall by brackets.
10250 DATA  T,bracket,brackets,*
10260 DATA   A,PR,Just plain iron brackets.
10270 DATA  T,floor,markings,*
10280 DATA   A,PR,You can make no sense of the markings but you can see they are well carved.
10290 DATA  T,leave,*
10300 DATA   A,GO,U
10310 DATA  C,U,*,10
10320 DATA L,13
10330 DATA  D,*,In the churchyard.
10340 DATA  T,dig,grave,headstone,tomb,*
10350 DATA   A,PR,Careful... they bury grave robbers around here!
10360 DATA  T,n,north,church,*-F4
10370 DATA   A,PR,You trip over a black cat which appears from behind a headstone!
10380 DATA   A,ZI,12
10390 DATA   A,AF,4,T
10400 DATA   A,IC,0,20
10410 DATA  T,church,*
10420 DATA   A,GO,N
10430 DATA  T,woods,*
10440 DATA   A,GO,W
10450 DATA  C,N,*,10
10460 DATA  C,W,*,18
10470 DATA L,14
10480 DATA  D,*,The road.
10490 DATA  D,*-V14,You know this road well. To the north it passes by the mill on its way to town.
10500 DATA  T,w,west,*F8
10510 DATA   A,PR,WHOOPS! You tripped and split the water.
10520 DATA   A,AF,8,F
10530 DATA  T,follow road,along road,*
10540 DATA   A,GO,N
10550 DATA  C,W,*,4
10560 DATA  C,N,*,15
10570 DATA L,15
10580 DATA  D,*,On a bridge over a stream.
10590 DATA  T,water,stream,fill,down,d,*
10600 DATA   A,PR,The stream is totally inaccessable from here.
10610 DATA  C,S,*,14
10620 DATA  C,N,*,16
10630 DATA L,16
10640 DATA  D,*,The mill.
10650 DATA  T,listen,*-F7
10660 DATA   A,PR,You can hear a faint scurrying noise. You wonder if it is a rat.
10670 DATA  T,rafters,*-F7
10680 DATA   A,PR,Something is making noises. You wonder if it is a rat.
10690 DATA  T,rat,rats,*-F7
10700 DATA   A,PR,Rat! Pah! I'm a mouse you fool.
10710 DATA  T,feed mouse,drop cheese,*C4
10720 DATA   A,PR,The mouse scurries down and nibbles the cheese.
10730 DATA   A,AF,7,T
10740 DATA   A,ZO,4
10750 DATA  T,catch mouse,get mouse,take mouse,pick up mouse,*F7.C1.-(W1/F8)
10760 DATA   A,GE
10770 DATA   A,PR,You caught the mouse in the hat.
10780 DATA  T,catch mouse,get mouse,take mouse,pick up mouse,*F7
10790 DATA   A,PR,He slips through your fingers.
10800 DATA  T,cheese,*F7.(O6/C6)
10810 DATA   A,PR,The mouse holds onto the cheese.
10820 DATA  T,flour,sack,grain,bag,mill,*-F9
10830 DATA   A,PR,The miller growls at you!
10840 DATA  T,give,*F8.-F9
10850 DATA   A,PR,"The miller puts the sack down, takes the hat and drinks some water."
10860 DATA   A,PR,He says "Ta lad." and then purs the rest over his head. As he does this you notice that the hat is too small for him to wear.
10870 DATA   A,IS,10
10880 DATA   A,AF,8,F
10890 DATA   A,ZI,10
10900 DATA   A,AF,9,T
10910 DATA  T,give,*F8.F9
10920 DATA   A,PR,He smiles and says "Go away creep."
10930 DATA  C,S,*,15
10940 DATA  C,W,*,17
10950 DATA L,17
10960 DATA  D,*,By the stream.
10970 DATA  D,*-V17,A loud sploshing sound comes from the water wheel. The water looks as fresh and clear as ever.
10980 DATA  T,fill,*C1.-(W1/C6)
10990 DATA   A,PR,If you insist.
11000 DATA   A,AF,8,T
11010 DATA  T,fill hat,*W1
11020 DATA   A,PR,Gargle...gargle...bubble! You are unable to hold your breath any longer and take your head out of the stream.
11030 DATA  T,mill,*
11040 DATA   A,GO,E
11050 DATA  C,E,*,16
11060 DATA L,18
11070 DATA  D,*,In the deep dark woods.
11080 DATA  D,*-V18,Careful! You might get lost!
11090 DATA  C,E,*,13
11100 DATA  C,W,*,19
11110 DATA L,19
11120 DATA  D,*,In the deep dark woods.
11130 DATA  C,E,*,18
11140 DATA  C,S,*,20
11150 DATA  C,W,*,21
11160 DATA L,20
11170 DATA  D,*,In the deep dark woods.
11180 DATA  C,W,*,23
11190 DATA  C,N,*,19
11200 DATA  C,S,*,22
11210 DATA  C,E,*,21
11220 DATA L,21
11230 DATA  D,*,In the deep dark woods.
11240 DATA  C,W,*,20
11250 DATA  C,E,*,21
11260 DATA  C,S,*,23
11270 DATA L,22
11280 DATA  D,*,In the deep dark woods.
11290 DATA  C,N,*,20
11300 DATA  C,E,*,23
11310 DATA L,23
11320 DATA  D,*,In the deep dark woods.
11330 DATA  D,*-V23,As you arrived you thought you saw someone run away.
11340 DATA  C,N,*,20
11350 DATA  C,E,*,24
11360 DATA  C,W,*,22
11370 DATA L,24
11380 DATA  D,*,In a clearing in the woods.
11390 DATA  D,*-W1,It is sheltered from the wind here and the sun is uncomfortably hot.
11400 DATA  D,*-V24,You hear a loud chopping sound to the south.
11410 DATA  T,s,south,*-V25.W1
11420 DATA   A,IS,10
11430 DATA   A,GO,S
11440 DATA  C,W,*,22
11450 DATA  C,S,*,25
11460 DATA L,25
11470 DATA  D,*,The wood cutter's hut.
11480 DATA  T,hut,*
11490 DATA   A,PR,The woodcutter bars your way. "I've already had my gold stolen. I'm not going to lose anything else. Keep out!"
11500 DATA  C,N,*,24
11510 DATA O,0
11520 DATA  P,1
11530 DATA O,1
11540 DATA  D,*-F8,a witch's hat.
11550 DATA  D,*F8,a witch's hat full of water.
11560 DATA  P,23
11570 DATA  N,hat,*
11580 DATA  S,EX,*,It has a label on the inside which says 'ACME Witch's Hat - SIZE 9'. You wonder who wears a size 9 hat!
11590 DATA  S,GE,*
11600 DATA  S,DR,*-(F8/C6)
11610 DATA  S,PO,*-(F8/C6)
11620 DATA  S,TO,*
11630 DATA O,2
11640 DATA  D,*-F3,a small wart-covered toad.
11650 DATA  D,*F3,a wet and frightened goat herd.
11660 DATA  P,8
11670 DATA  S,GE,*-F3
11680 DATA  S,DR,*
11690 DATA  N,toad,boy,herd,*
11700 DATA  S,EX,*-F3,a very human looking toad.
11710 DATA  S,EX,*F3,a very toady looking human.
11720 DATA O,3
11730 DATA  D,*,several ducks.
11740 DATA  P,7
11750 DATA  N,ducks,duck,*
11760 DATA  S,EX,*,They seem to be sitting on something.
11770 DATA O,4
11780 DATA  D,*,a small piece of cheese.
11790 DATA  P,3
11800 DATA  N,cheese,*
11810 DATA  S,GE,*
11820 DATA  S,DR,*
11830 DATA  S,EX,*,Looks a bit cheesy!
11840 DATA O,5
11850 DATA  D,*,a loaf of bread.
11860 DATA  P,3
11870 DATA  N,loaf,bread,*
11880 DATA  S,GE,*
11890 DATA  S,DR,*
11900 DATA O,6
11910 DATA  D,*-F7,something moving around the rafters.
11920 DATA  D,*F7.-C6,a piece of cheese with a mouse attached to it.
11930 DATA  D,*F7.C6,the mouse and the cheese in the hat.
11940 DATA  P,16
11950 DATA  N,mouse,cheese,*F7
11960 DATA  S,GE,*
11970 DATA  S,DR,*
11980 DATA O,7
11990 DATA  D,*,a large brass bell.
12000 DATA  P,11
12010 DATA  N,bell,*
12020 DATA  S,EX,*,a large church bell inscribed with the letters 'ring me!'.
12030 DATA O,8
12040 DATA  D,*,a lot of goats.
12050 DATA  P,5
12060 DATA  N,goat,goats,*
12070 DATA  S,EX,*,They are tethered to posts. Strange! They seem to have eaten all the good grass they can reach. Perhaps they have not been moved for a while?
12080 DATA O,9
12090 DATA  D,*-(F1/F2),a very small priest blessing the secret crypt.
12100 DATA  D,*-F1.-F2,a very agitated priest looking up at the belfrey.
12110 DATA  D,*F2,a priest wearing a black hat over his head and shoulders!
12120 DATA  P,12
12130 DATA  N,priest,*
12140 DATA  S,Ex,*,He looks very small to you.
12150 DATA O,10
12160 DATA  D,*,a sack of flour.
12170 DATA  P,-1
12180 DATA  N,sack,bag,flour,*
12190 DATA  S,GE,*
12200 DATA  S,DR,*
12210 DATA  S,EX,*,It is labelled 'MegaMill Flour Co.'
12220 DATA O,11
12230 DATA  D,*-V25,an out of breath woodcutter resting on his axe.
12240 DATA  D,*-V25.W1,Suddenly the woodcutter snatches the hat and trys it on. "I wonder if this will shield me from the sun?" he says. "Pity... not my size." he grumbles and replaces the hat on your head.
12250 DATA  D,*V25,the woodcutter hard at work.
12260 DATA  P,25
12270 DATA  N,woodcutter,*
12280 DATA  S,EX,*,A rather hot sweaty woodcutter.
12290 DATA O,12
12300 DATA  D,*F7,a friendly black cat drooling around your ankles.
12310 DATA  D,*-F7,a friendly black cat.
12320 DATA  P,-1
12330 DATA  N,cat,*
12340 DATA  S,EX,+,It looks friendly.
12350 DATA O,13
12360 DATA  D,*,the innkeeper.
12370 DATA  P,3
12380 DATA  N,innkeeper,*
12390 DATA  S,EX,*,He is rather large.
12400 DATA O,14
12410 DATA  D,*,some gold coins!
12420 DATA  P,-1
12430 DATA  N,coins,gold,*
12440 DATA  S,GE,*
12450 DATA  S,DR,*
12460 DATA  S,EX,*,No. They are not sliced golden egg. They must have come from somewhere else.
12470 DATA O,15
12480 DATA  D,*,The miller humping sacks about.
12490 DATA  P,16
12500 DATA  N,miller,*
12510 DATA  S,EX,*-F9,He looks hot and thirsty.
12520 DATA  S,Ex,*F9,He looks wet.
12530 DATA O,16
12540 DATA  D,*-F10,The blacksmith hard at work.
12550 DATA  D,*F10,The blacksmith in the stocks.
12560 DATA  P,9
12570 DATA  N,blacksmith,smith,*
12580 DATA  S,EX,*-F10,He looks rather hot.
12590 DATA  S,EX,*F10,He looks stuck.
12600 DATA O,17
12610 DATA  D,*,some stocks.
12620 DATA  P,4
12630 DATA  N,stocks,*
12640 DATA  S,EX,*-F10,There is a brass plaque with 'Made by OXO' engraved in it.
12650 DATA  S,EX,*F10,There seems to be a blacksmith in them!!!
12660 DATA E,0
12670 DATA  A,PR," "
12680 DATA  A,PR,A crowd of villagers gather round you. The priest points at the cat and says "Look he has a black cat familiar! That proves he is a witch.". They drag you away and test your inflammability.
12690 DATA  A,SC
12700 DATA  A,QU
12710 DATA E,1
12720 DATA  A,PR,The church bell rings. It is midday. The villagers drag you away and burn you. It was a really jolly occasion and people came from miles around to see you.
12730 DATA  A,SC
12740 DATA  A,QU
12750 DATA F
