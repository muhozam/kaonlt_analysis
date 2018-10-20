C  VAX VERSIONS OF NBS CODES
C     PROGRAM QFSV
      SUBROUTINE QFSV(E0,EFIN,THET,PFERMI,EPS1,EPSD1,Z1,A1,SIGMA)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL RADF
      COMMON/PAR/E,TH,W,Z,A,EPS,EPSD,PF,SPENCE
C
C  CALCULATE QUASIELASTIC, TWO-NUCLEON, RESONANCE, AND X-SCALING
C  ELECTRON SCATTERING CROSS SECTION FOR ARBITRARY NUCLEI
C
C  WRITTEN BY J.W. LIGHTBODY JR. AND J.S. O'CONNELL
C  NATIONAL BUREAU OF STANDARDS, GAITHERSBURG, MD 20899
C  OCTOBER 1987
C
      DATA SCALE/1.D7/
      E = E0
      Z = Z1
      A = A1
      PF = PFERMI
      EPS = EPS1
      EPSD = EPSD1
      PM=939.D0
      DM=1232.D0
      ALPH=1./137.03604D0
      HBARC=197.32858D0
      PI=ACOS(-1.)
      RADF = .FALSE.                    !Don't radiate cross section
C
      W = E - EFIN              !energy loss
      TH = THET*180./PI         !degrees
      SIGQFZA = SIGQFS(E,TH,W,Z,A,EPS,PF)*SCALE
      SIGDA   = SIGDEL(E,TH,W,A,EPSD,PF) *SCALE
      SIGXA   = SIGX(E,TH,W,A)           *SCALE
      SIGR1A  = SIGR1(E,TH,W,A,PF)       *SCALE
      SIGR2A  = SIGR2(E,TH,W,A,PF)       *SCALE
      SIG2NA  = SIG2N(E,TH,W,Z,A,PF)     *SCALE
      SIGMA_NR =  SIGQFZA+SIGDA+SIGXA+SIGR1A+SIGR2A+SIG2NA
C
      IF(RADF)THEN
        CALL RADIATE(E,TH,W,SIGMA_NR,SIGMA)    !nb/MeV/c/sr.80.80


      ELSE
        SIGMA = SIGMA_NR
      ENDIF
c      write(6,*) 'sigma is', sigma
C
C
      RETURN
      END
C
C
*FD
      DOUBLE PRECISION FUNCTION FD(QMS,A)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      FD=1./(1.+QMS/A**2)**2
      RETURN
      END
*FM
      DOUBLE PRECISION FUNCTION FM(QMS,A)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      FM=1./(1.+QMS/A**2)
      RETURN
      END
*FPHENOM
      DOUBLE PRECISION FUNCTION FPHENOM(QMS)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      A1=.55
      A2=20./1.E6
      B1=.45
      B2=.45/1.E6
      C1=0.03
      C2=0.2/1.E12
      FPHENOM=A1*EXP(-A2*QMS)+B1*EXP(-B2*QMS)
      FPHENOM=FPHENOM+C1*EXP(-C2*(QMS-4.5E6)**2)
      FPHENOM=SQRT(FPHENOM)
      RETURN
      END
*FYUKAWA
      DOUBLE PRECISION FUNCTION FYUKAWA(QMS,A)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      IF(QMS.LT.1.E-5.OR.A.LT.1.E-5)THEN
        FYUKAWA=0.
      ELSE
        ARG=SQRT(QMS/2.)/A
        FYUKAWA=ATAN(ARG)/ARG
      ENDIF
      RETURN
      END
*SIGMOT
      DOUBLE PRECISION FUNCTION SIGMOT(E,THR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      ALPH=1./137.03604
      HBARC=197.3286
      SIGMOT=(ALPH*HBARC*COS(THR/2.)/2./E/SIN(THR/2.)**2)**2
C  FM**2/SR
      RETURN
      END
*RECOIL
      DOUBLE PRECISION FUNCTION RECOIL(E,THR,TM)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      RECOIL=1./(1.+2.*E*SIN(THR/2.)**2/TM)
      RETURN
      END
*SIGX
      DOUBLE PRECISION FUNCTION SIGX(E,TH,W,A)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      ALPH=1./137.03604
      PI=ACOS(-1.)
C     SIG0=111.*1.E-30
      SIG0=100.D-4
C     SIG1=60.*1.E-27
      SIG1=54.*1.D-1
      PIMASS=140.
      PM=939.
C     GAM0=550.
      GAM0=650.
C     R=0.10
      AQ=250.
      THR=TH*PI/180.
      IF(W.LT.1.E-5)GO TO 4
      QMS=4.*E*(E-W)*SIN(THR/2.)**2
      ARG0=W-QMS/2./PM-PIMASS-PIMASS**2/2./PM
      ARG1=ARG0/GAM0
      ARG=ARG1**2/2.
      IF(ARG1.GT.8.)THEN
        SHAPE=1.+SIG1/SIG0/ARG0
      ELSEIF(ARG1.LT.1.E-5)THEN
        SHAPE=0.
      ELSEIF(ARG1.LT.0.1)THEN
        SHAPE=SIG1*ARG0/2./GAM0**2/SIG0
      ELSE
        SHAPE=(1.-EXP(-ARG))*(1.+SIG1/SIG0/ARG0)
      ENDIF
      EKAPPA=W-QMS/2./PM
      SIGGAM=SIG0*SHAPE
      QS=QMS+W**2
      EPS=1./(1.+2.*QS*TAN(THR/2.)**2/QMS)
      FLUX=ALPH*EKAPPA*(E-W)/2./PI**2/QMS/E/(1.-EPS)
      IF(FLUX.LT.1.E-20)FLUX=0.
      SIGEE=FLUX*SIGGAM*FPHENOM(QMS)**2
C     SIGEE=FLUX*SIGGAM
      R=0.56*1.E6/(QMS+PM**2)
      FACTOR1=1.+EPS*R
      SIGEE=SIGEE*FACTOR1
    4 SIGX=A*SIGEE
      RETURN
      END
*SIGR1
      DOUBLE PRECISION FUNCTION SIGR1(E,TH,W,A,PF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PI=ACOS(-1.)
      PM=939.
      PIMASS=140.
      THR=TH*PI/180.
      PFR=230.
      RM=1500.
      EPSR=0.
      AR0=1000.
      AR1=1000.
      GAMQFR=120.
      GAMSPRD=140.
      GAMR=110.
      GAMPI=5

      QFRP=1.20D-7
      QMSQFR=4.*730.*(730.-115.)*SIN(37.1*PI/180./2.)**2
      QVSQFR=QMSQFR+115.**2
      QMSRR=4.*10000.*(10000.-1240.)*SIN(6.*PI/180./2.)**2
      QVSRR=QMSRR+1240.**2
      SIGREF=FD(QMSRR,AR0)**2*QVSRR
      SIGREF=SIGREF*(QMSRR/2./QVSRR+TAN(6.*PI/180./2.)**2)
      SIGREF=SIGREF*SIGMOT(10000.D0,6.*PI/180.)
      NA=INT(A)
      IF(NA.EQ.1)THEN
        QFR=QFRP
        GSPRDA=0.
        AR=AR0
      ELSEIF(NA.LT.4)THEN
        QFR=QFRP
        GSPRDA=(A-1.)*GAMSPRD/3.
        AR=AR0+(A-1.)*(AR1-AR0)/3.
      ELSE
        AR=AR1
        GSPRDA=GAMSPRD
        QFR=QFRP
      ENDIF

      QMS=4.*E*(E-W)*SIN(THR/2.)**2
      QVS=QMS+W**2
      IF(NA.GT.1)THEN
        GAMQ=GAMQFR*PF*SQRT(QVS)/PFR/SQRT(QVSQFR)
      ELSE
        GAMQ=0.
      ENDIF
      CMTOT2=PM**2+2.*PM*W-QMS
      WTHRESH=4.*E**2*SIN(THR/2.)**2+PIMASS**2+2.*PIMASS*PM
      WTHRESH=WTHRESH/2./PM
      THRESHD=1.+PF/PM+PF**2/2./PM**2+2.*E*SIN(THR/2.)**2/PM
      WTHRESH=WTHRESH/THRESHD
      IF(W.GT.WTHRESH)THEN
        THRESH=1.-EXP(-(W-WTHRESH)/GAMPI)
      ELSE
        THRESH=0.
      ENDIF
      EPR=E-(RM-PM)*(RM+PM)/2./PM
      EPR=EPR/(1.+2.*E*SIN(THR/2.)**2/PM)
      EPR=EPR-EPSR
      WR=E-EPR
      GAM=SQRT(GAMR**2+GAMQ**2+GSPRDA**2)
      SIGR=QFR*(GAMR/GAM)/SIGREF
      SIGR=SIGR*CMTOT2*GAM**2
      SIGR=SIGR/((CMTOT2-(RM+EPSR)**2)**2+CMTOT2*GAM**2)
      SIGR=SIGR*QVS*FD(QMS,AR)**2
      SIGR=SIGR*(QMS/2./QVS+TAN(THR/2.)**2)
      SIGR=SIGR*SIGMOT(E,THR)

      SIGR1=A*THRESH*SIGR
      RETURN
      END
*SIGR2
      DOUBLE PRECISION FUNCTION SIGR2(E,TH,W,A,PF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PI=ACOS(-1.)
      PM=939.
      PIMASS=140.
      THR=TH*PI/180.
      PFR=230.
      RM=1700.
      EPSR=0.
      AR0=1200.
      AR1=1200.
      GAMQFR=120.
      GAMSPRD=140.
      GAMR=110.
      GAMPI=5.
      QFRP=0.68D-7
      QMSQFR=4.*730.*(730.-115.)*SIN(37.1*PI/180./2.)**2
      QVSQFR=QMSQFR+115.**2
      QMSRR=4.*10000.*(10000.-1520.)*SIN(6.*PI/180./2.)**2
      QVSRR=QMSRR+1520.**2
      SIGREF=FD(QMSRR,AR0)**2*QVSRR
      SIGREF=SIGREF*(QMSRR/2./QVSRR+TAN(6.*PI/180./2.)**2)
      SIGREF=SIGREF*SIGMOT(10000.D0,6.*PI/180.)
      NA=INT(A)
      IF(NA.EQ.1)THEN
        QFR=QFRP
        GSPRDA=0.
        AR=AR0
      ELSEIF(NA.LT.4)THEN
        QFR=QFRP
        GSPRDA=(A-1.)*GAMSPRD/3.
        AR=AR0+(A-1.)*(AR1-AR0)/3.
      ELSE
        AR=AR1
        GSPRDA=GAMSPRD
        QFR=QFRP
      ENDIF
      QMS=4.*E*(E-W)*SIN(THR/2.)**2
      QVS=QMS+W**2
      IF(NA.GT.1)THEN

        GAMQ=GAMQFR*PF*SQRT(QVS)/PFR/SQRT(QVSQFR)
      ELSE
        GAMQ=0.
      ENDIF
      CMTOT2=PM**2+2.*PM*W-QMS
      WTHRESH=4.*E**2*SIN(THR/2.)**2+PIMASS**2+2.*PIMASS*PM
      WTHRESH=WTHRESH/2./PM
      THRESHD=1.+PF/PM+PF**2/2./PM**2+2.*E*SIN(THR/2.)**2/PM
      WTHRESH=WTHRESH/THRESHD
      IF(W.GT.WTHRESH)THEN
        THRESH=1.-EXP(-(W-WTHRESH)/GAMPI)
      ELSE
        THRESH=0.
      ENDIF
      EPR=E-(RM-PM)*(RM+PM)/2./PM
      EPR=EPR/(1.+2.*E*SIN(THR/2.)**2/PM)
      EPR=EPR-EPSR
      WR=E-EPR
      GAM=SQRT(GAMR**2+GAMQ**2+GSPRDA**2)
      SIGR=QFR*(GAMR/GAM)/SIGREF
      SIGR=SIGR*CMTOT2*GAM**2
      SIGR=SIGR/((CMTOT2-(RM+EPSR)**2)**2+CMTOT2*GAM**2)
      SIGR=SIGR*QVS*FD(QMS,AR)**2
      SIGR=SIGR*(QMS/2./QVS+TAN(THR/2.)**2)
      SIGR=SIGR*SIGMOT(E,THR)
      SIGR2=A*THRESH*SIGR
      RETURN
      END

*SIG2N
      DOUBLE PRECISION FUNCTION SIG2N(E,TH,W,Z,A,PF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PI=ACOS(-1.)
      THR=TH*PI/180.
      DM=1232.
      PIMASS=140.
      PM=940.
      A2=550.
      PFR=60.
      GAM2N=20.
      GAMQFR=40.
      GAMREF=300.
      GAMR=GAMREF
      SIGREF=0.20D-7
      QMSR=4.*596.8*(596.8-380.)*SIN(60.*PI/180./2.)**2
      QVSR=QMSR+380.**2
      SIGKIN=0.5*SIGMOT(596.8D0,60.*PI/180.)
      SIGKIN=SIGKIN*(QMSR/2./QVSR+TAN(60.*PI/180./2.)**2)
      SIGKIN=SIGKIN*QVSR*FD(QMSR,A2)**2
      SIGKIN=SIGKIN*GAMR/GAMREF
      SIGCON=SIGREF/SIGKIN
      QMS=4.*E*(E-W)*SIN(THR/2.)**2
      QVS=QMS+W**2
      GAMQF=GAMQFR*(PF/PFR)*(SQRT(QVS)/SQRT(QVSR))
      EFFMASS=(PM+DM)/2.
      SIG=(Z*(A-Z)/A)*SIGMOT(E,THR)
      SIG=SIG*(QMS/2./QVS+TAN(THR/2.)**2)
      SIG=SIG*QVS*FD(QMS,A2)**2.80

      EKAPPA=W-QMS/2./PM
      CMTOT2=PM**2+2.*PM*EKAPPA
C     GAM=SQRT(GAMR**2+GAMQF**2)
      GAM=GAMR
      SIG=SIG*CMTOT2*GAM**2
      SIG=SIG/((CMTOT2-EFFMASS**2)**2+CMTOT2*GAM**2)
      SIG=SIG*(GAMR/GAM)*SIGCON
      SIG2N=SIG
      WTHRESH=QMS/4./PM
      IF(W.GT.WTHRESH)THEN
        THRESH=1.-EXP(-(W-WTHRESH)/GAM2N)
      ELSE
        THRESH=0.
      ENDIF
      SIG2N=SIG2N*THRESH
      RETURN
      END
*SIGDEL
      DOUBLE PRECISION FUNCTION SIGDEL(E,TH,W,A,EPSD,PF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PM=939.
      PIMASS=140

      DM=1219.
      AD1=700.
      AD0=774.
      PI=ACOS(-1.)
      ALPH=1./137.03604
      HBARC=197.32858
      GAMDP=110.
      GAMSPRD=140.
      GAMR=120.
      GAMPI=5.
      QFDP=1.02D-7
      PFR=230.
      QMSR=4.*730.*(730.-390.)*SIN(37.1*PI/180./2.)**2
      QVSR=QMSR+390.**2
      QMSRQ=4.*730.*(730.-115.)*SIN(37.1*PI/180./2.)**2
      QVSRQ=QMSRQ+115.**2
      NA=INT(A)
      IF(NA.EQ.1)THEN
        QFD=QFDP
        GSPRDA=0.
        AD=AD0
      ELSEIF(NA.LT.4)THEN
        QFD=QFDP
        GSPRDA=(A-1.)*GAMSPRD/3.
        AD=AD0+(A-1.)*(AD1-AD0)/3.
      ELSE
        AD=AD1
        GSPRDA=GAMSPRD
        QFD=QFDP
      ENDIF
      THR=TH*PI/180.
      QMS=4.*E*(E-W)*SIN(THR/2.)**2
      QVS=QMS+W**2
      EKAPPA=W-QMS/2./PM
      CMTOT2=PM**2+2.*PM*EKAPPA
C  BEGIN DELTA CALCULATION
      IF(NA.GT.1)THEN

        GAMQ=GAMR*PF*SQRT(QVS)/PFR/SQRT(QVSRQ)
      ELSE
        GAMQ=0.
      ENDIF
      EPD=E-(DM-PM)*(DM+PM)/2./PM
      EPD=EPD/(1.+2.*E*SIN(THR/2.)**2/PM)
      EPD=EPD-EPSD
      WD=E-EPD
      QMSPK=4.*E*EPD*SIN(THR/2.)**2
      QVSPK=QMSPK+WD**2
C
C NOTE WIDTH INCLUDES E-DEPENDENCE,FERMI BROADENING,& SPREADING
C
      WTHRESH=4.*E**2*SIN(THR/2.)**2+PIMASS**2+2.*PIMASS*PM
      WTHRESH=WTHRESH/2./PM
      THRESHD=1.+PF/PM+PF**2/2./PM**2+2.*E*SIN(THR/2.)**2/PM
      WTHRESH=WTHRESH/THRESHD
      IF(W.GT.WTHRESH)THEN
        THRESH=1.-EXP(-(W-WTHRESH)/GAMPI)
      ELSE
        THRESH=0.
      ENDIF
      GAMD=GAMDP
      GAM=SQRT(GAMD**2+GAMQ**2+GSPRDA**2)
      SIGD=QFDP*(GAMDP/GAM)
      SIGD=SIGD*CMTOT2*GAM**2
      SIGD=SIGD/((CMTOT2-(DM+EPSD)**2)**2+CMTOT2*GAM**2)
      SIGD=SIGD*FD(QMS,AD)**2/FD(QMSR,AD)**2
      TEST=QVS/QVSR
      SIGD=SIGD*TEST
      SIGD=SIGD*(QMS/2./QVS+TAN(THR/2.)**2)
      SIGD=SIGD/(QMSR/2./QVSR+TAN(37.1*PI/180./2.)**2)
      SIGD=SIGD*SIGMOT(E,THR)/SIGMOT(730.D0,37.1*PI/180.)
      SIGD=SIGD*A
      SIGD=SIGD*THRESH
      SIGDEL=SIGD
      RETURN
      END
*SIGQFS
      DOUBLE PRECISION FUNCTION SIGQFS(E,TH,W,Z,A,EPS,PF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PM=939.
      UP=2.7928456
      UN=-1.91304184
      AP0=840.
      AP1=750.
      ALPH=1./137.03604
      HBARC=197.32858
      PI=ACOS(-1.)
      GAMR=120

      PFR=230.
      QMSRQ=4.*730.*(730.-115.)*SIN(37.1*PI/180./2.)**2
      QVSRQ=QMSRQ+115.**2
      NA=INT(A)
      IF(NA.EQ.1)THEN
        AP=AP0
      ELSEIF(NA.LT.4)THEN
        AP=AP0+(A-1.)*(AP1-AP0)/3.
      ELSE
        AP=AP1
      ENDIF
C     PRINT 200
  200 FORMAT(' ENTER DE-E[MEV],DOMEGA-E[SR],B-LUMINOSITY[CM-2*S-1]')
C     READ *,DEE,DWE,BLUM
      THR=TH*PI/180.
      QMS=4.*E*(E-W)*SIN(THR/2.)**2
      QVS=QMS+W**2
      EKAPPA=W-QMS/2./PM
      IF(EKAPPA.GT.-PM/2.)THEN
        CMTOT=SQRT(PM**2+2.*PM*EKAPPA)
      ELSE
        CMTOT=PM
      ENDIF
C  START QFS SECTION
      SIGNS=SIGMOT(E,THR)*RECOIL(E,THR,PM)
      FORMP=1.+QMS*UP**2/4./PM**2
      FORMP=FORMP/(1.+QMS/4./PM**2)
      FORMP=FORMP+QMS*UP**2*TAN(THR/2.)**2/2./PM**2
      FORMP=FORMP*FD(QMS,AP)**2
      SIGEP=SIGNS*FORMP
      FALLOFF=(1.+5.6*QMS/4./PM**2)**2
      FORMN=(QMS*UN/4./PM**2)**2/FALLOFF+QMS*UN**2/4./PM**2
      FORMN=FORMN/(1.+QMS/4./PM**2)
      FORMN=FORMN+QMS*UN**2*TAN(THR/2.)**2/2./PM**2
      FORMN=FORMN*FD(QMS,AP)**2
      SIGEN=SIGNS*FORMN
      EPQ=4.*E**2*SIN(THR/2.)**2/2./PM
      EPQ=EPQ/(1.+2.*E*SIN(THR/2.)**2/PM)+EPS

      EPQ=E-EPQ
      IF(INT(A).EQ.1)THEN
        ARG=(E-W-EPQ)/SQRT(2.)/1.
        DEN=2.51
      ELSE
        GAMQ=GAMR*PF*SQRT(QVS)/PFR/SQRT(QVSRQ)
        ARG=(E-W-EPQ)/1.20/(GAMQ/2.)
        DEN=2.13*(GAMQ/2.)
      ENDIF
      NQ=INT(ARG)
      IF(ABS(NQ).GT.10)THEN
        SIGQ=0.
      ELSE
        SIGQ=(Z*SIGEP+(A-Z)*SIGEN)*EXP(-ARG**2)/DEN
      ENDIF
      SIGQFS=SIGQ
      RETURN
      END
*RADIATE
      SUBROUTINE RADIATE(E,TH,W,SIGNR,SIGRAD)
C     DOES NOT INCLUDE CONTRIBUTION FROM ELASTIC SCATTERING
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/PAR/E0,TH0,W0,Z,A,EPS,EPSD,PF,SPENCE
      ALPH=1./137.03604
      EMASS=0.511
      DEL=10.
      PI=ACOS(-1.)
      PREC=.01
      THR=TH*PI/180.
      ARG=COS(THR/2.)**2
      SPENCE=PI**2/6.-LOG(ARG)*LOG(1.-ARG)
      DO 10 NSP=1,50
   10 SPENCE=SPENCE-ARG**NSP/FLOAT(NSP)**2
C     PRINT 15,SPENCE
   15 FORMAT(' SPENCE FUNCTION = ',1F14.9)
      QMS=4.*E*(E-W)*SIN(THR/2.)**2
      D1=(2.*ALPH/PI)*(LOG(QMS/EMASS**2)-1.)
      D2=13.*(LOG(QMS/EMASS**2)-1.)/12.-17./36.-0.5*(PI**2/6.-SPENCE)
      D2=D2*(2.*ALPH/PI)
      EBAR=SQRT(E*(E-W))

      SIGRAD=SIGNR*(1.+D2)*EXP(-D1*LOG(EBAR/DEL))
C     PRINT 20,D1,D2
   20 FORMAT(' DELTA1 AND DELTA2 = ',2E14.6)
      X1=0.
      X2=W-DEL
      CALL ROM(X1,X2,PREC,ANS,KF)
      ANS=ANS*1.D7
      IFLAG=0
      ERR=0.
C     PRINT 25,X1,X2,PREC,ANS,ERR
   25 FORMAT(' X1,X2,PREC,ANS,ERR = ',5E10.3)
C     PRINT 30,KF,IFLAG
   30 FORMAT(' KF,IFLAG = ',2I5)
      SIGRAD=SIGRAD+ANS
      RETURN
      END
*QFSVAL
      SUBROUTINE QFSVAL(X,F)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     DOUBLE PRECISION FUNCTION F(X)
      COMMON/PAR/E,TH,W,Z,A,EPS,EPSD,PF,SPENCE
      ALPH=1./137.03604
      EMASS=.511
      PI=ACOS(-1.)
      THR=TH*PI/180.
      SIG1=SIGQFS(E,TH,X,Z,A,EPS,PF)
      SIG1=SIG1+SIGDEL(E,TH,X,A,EPSD,PF)
      SIG1=SIG1+SIGX(E,TH,X,A)
      SIG1=SIG1+SIGR1(E,TH,X,A,PF)
      SIG1=SIG1+SIGR2(E,TH,X,A,PF)
      SIG1=SIG1+SIG2N(E,TH,X,Z,A,PF)
      SIG2=SIGQFS(E-W+X,TH,X,Z,A,EPS,PF)
      SIG2=SIG2+SIGDEL(E-W+X,TH,X,A,EPSD,PF)
      SIG2=SIG2+SIGX(E-W+X,TH,X,A)
      SIG2=SIG2+SIGR1(E-W+X,TH,X,A,PF)
      SIG2=SIG2+SIGR2(E-W+X,TH,X,A,PF)
      SIG2=SIG2+SIG2N(E-W+X,TH,X,Z,A,PF)
      QMS1=4.*E*(E-X)*SIN(THR/2.)**2
      QMS2=4.*(E-W+X)*(E-W)*SIN(THR/2.)**2
      QMSBAR=SQRT(QMS1*QMS2)
      F1=(LOG(QMS1/EMASS**2)-1.)/2./(E-X)**2
      F1=F1*SIG1
      F1=F1*ALPH*((E-X)**2+(E-W)**2)/(W-X)/PI
      F2=SIG2*(LOG(QMS2/EMASS**2)-1.)/2./E**2
      F2=F2*ALPH*(E**2+(E-W+X)**2)/(W-X)/PI
      D1=(2.*ALPH/PI)*(LOG(QMSBAR/EMASS**2)-1.)
      D2=13.*(LOG(QMSBAR/EMASS**2)-1.)/12.-17./36.
      D2=(2.*ALPH/PI)*(D2-0.5*(PI**2/6.-SPENCE))
      EBAR=SQRT((E-X)*(E-W))
      F=(F1+F2)*(1.+D2)*((W-X)/EBAR)**D1
      RETURN
      END
      SUBROUTINE ROM(A,B,EPS,ANS,K)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C  ROMBERG METHOD OF INTEGRATION
      DIMENSION W(50,50)
      H=B-A
      K=0
      CALL QFSVAL(A,FA)
      CALL QFSVAL(B,FB)
      W(1,1)=(FA+FB)*H/2.
    4 K=K+1
      IF(K.GE.49)GO TO 5
      H=H/2.
      SIG=0.
      M=2**(K-1)
      DO 1 J=1,M
        J1=2*J-1
        X=A+FLOAT(J1)*H
        CALL QFSVAL(X,F)
    1 SIG=SIG+F
      W(K+1,1)=W(K,1)/2.+H*SIG
      DO 2 L=1,K
        IU=K+1-L
        IV=L+1
    2 W(IU,IV)=(4.**(IV-1)*W(IU+1,IV-1)-W(IU,IV-1))/(4.**(IV-1)-1.)
      IF(W(IU,IV) .NE. 0.)THEN
        E=(W(IU,IV)-W(IU,IV-1))/W(IU,IV)
      ELSE
        GOTO 4
      ENDIF
      IF(ABS(E)-EPS) 3,3,4
    3 ANS=W(1,IV)
      RETURN
    5 PRINT 100
  100 FORMAT(' K OVERFLOW')
cxxx      CALL EXIT
      RETURN
      END
