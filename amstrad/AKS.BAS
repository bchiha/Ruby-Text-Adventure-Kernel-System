10 GOTO 60
20 POKE 429,lin MOD 256
30 POKE 430,lin\256
40 RESTORE 10
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
3820   IF INSTR("tf",dat$>=0 THEN GOSUB 3940 : REM *evalop*
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
5280   IF type$="S" THEN GOSUB 5360 * REM *suittest*
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
