DECLARE
	 @Rate 			FLOAT	= 7.9			-- The interest rate for the loan.
	,@Period 		INT		= 1				-- (Just leave at 1) Specifies the period and must be in the range 1 to nper
	,@PeriodYears	INT		= 5				-- Number of Years in Loan
	,@PeriodsInYear	INT		= 12			-- Periods Per Year (12 = Monthly)
	,@Present 		FLOAT	= 72000			-- The present value
	,@Future 		FLOAT	= 0				-- The future value
	,@Type 			INT  	= 0				-- 0 = End of Period , 1 = Start of Period

DECLARE
	 @RatePeriod	FLOAT	= @Rate / 100 / @PeriodsInYear
	,@TotalPeriods	INT		= @PeriodYears * @PeriodsInYear
	,@Repayment		FLOAT	= 0

SET 
	@Repayment				= dbo.PMT(@RatePeriod,@TotalPeriods,@Present,@Future,@Type) *-1


; WITH LoanCalc AS
(
	SELECT			 CAST(0 AS INT)																										AS 'nPeriod'
					,CAST(@Present AS MONEY)																							AS 'pCurrent'
					,CAST(@Repayment AS MONEY)																							AS 'Repayment'
					,CAST(0 AS MONEY)																									AS 'InterestRepay'
					,CAST(0 AS MONEY)																									AS 'PrincipalRepay'
					,CAST(0	AS MONEY)																									AS 'AccumulatedInterest'
					,CAST(@Present AS MONEY)																							AS 'RemainingBalance'
	UNION ALL
	SELECT			 CAST(nPeriod + 1 AS INT)																							AS 'nPeriod'
					,CAST(RemainingBalance AS MONEY)																					AS 'pCurrent'
					,CAST(@Repayment AS MONEY)																							AS 'Repayment'
					,CAST(dbo.IPMT(@RatePeriod, nPeriod+1, @TotalPeriods, @Present, @Future, @Type) * -1 AS MONEY)						AS 'InterestRepay'
					,CAST(dbo.PPMT(@RatePeriod, nPeriod+1, @TotalPeriods, @Present, @Future, @Type) * -1 AS MONEY)						AS 'PrincipalRepay'
					,CAST(dbo.CUMIPMT(@RatePeriod, @TotalPeriods, @Present, 1, nPeriod+1, @Type) * -1 AS MONEY)							AS 'AccumulatedInterest'
					,CAST(RemainingBalance - dbo.PPMT(@RatePeriod, nPeriod+1, @TotalPeriods, @Present, @Future, @Type) * -1 AS MONEY)	AS 'RemainingBalance'

	FROM		LoanCalc
	WHERE		nPeriod < @TotalPeriods
)	
SELECT * FROM LoanCalc OPTION (MAXRECURSION 100)


