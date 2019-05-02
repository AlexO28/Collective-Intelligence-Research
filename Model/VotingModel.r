## Scripts for simulation of our voting model. 
## Author: N.N.Osipov
###############################################


source("Model/MuSgmEstimation.r")


### Expected utility of a matched vote for $\omega = 1$.
#########################################################

UFor1 <- function(p, q, lmd)
{
	p * (1 - exp(-lmd)) / (1 - exp(-lmd * q))
}


### Expected utility of a matched vote against $\omega = 1$ (for $\omega = 0$).
################################################################################

UFor0 <- function(p, q, lmd)
{
	UFor1(1 - p, 1 - q, lmd)      #### (1 - p) * (1 - exp(-lmd)) / (1 - exp(-lmd * (1 - q)))
}


### Model of voting for a single coefficient.
##############################################

VModelForCoeff <- function(
		q,         # Voting coefficient.
		lmd,
		ThtPls, 
		ThtMns, 
		pp,        # Sequence of beliefs.
		rhoPls,    # Model probability of matching of an unmatched vote for $\theta = 1$. 
		rhoMns)    # Model probability of matching of an unmatched vote against $\theta = 1$ (for $\theta = 0$).
{
	VPls <- 0;
	VMns <- 0;

	for (p in pp)
	{
		if (p >= ThtMns)
		{
			VPls <- VPls + 1;
			next;
		}

		if (p <= ThtPls)
		{
			VMns <- VMns + 1;
			next;
		}

		if ((1 - q) * VPls >=  q * VMns)
		{
			if (rhoPls * UFor1(p, q, lmd) + (1 - rhoPls) >= UFor0(p, q, lmd))
			{
				VPls <- VPls + 1;
			}
			else
			{
				VMns <- VMns + 1;
			}
			
			next;
		}
			
		if (UFor1(p, q, lmd) <= rhoMns * UFor0(p, q, lmd) + (1 - rhoMns))
		{
			VMns <- VMns + 1;
		}
		else
		{
			VPls <- VPls + 1;
		}
	}

	cbind(VPls, VMns);
}


### Model of voting where coefficients are considered separately.
##################################################################

VModel <- function(votes, mu, sgm, lmd, rhoPlss, rhoMnss)
{
	qq <- rep(votes$q, votes$VPls + votes$VMns);
	pp <- rnorm(length(qq), mu, sgm);
	
	mdlVotes = data.frame();
	for (q in votes$q)
	{
		ThtPls <- Tht(q, lmd);
		ThtMns <- ThtCnj(q, lmd);
		rhoPls <- rhoPlss[votes$q == q];
		rhoMns <- rhoMnss[votes$q == q];
		mdlVotes <- rbind(mdlVotes, cbind(q, VModelForCoeff(q, lmd, ThtPls, ThtMns, pp[qq == q], rhoPls, rhoMns)));
	}

	mdlVotes;
}


lgs <- function(x, d, k) 
{
	1 / (1 + exp(-k * (x - d)));
}


logit <- function(x)
{
	log(x / (1 - x));
}


rhoCurve <- function(q, d, k)
{
	lgs(logit(q), d, k);
}


VtoS <- function(votes)
{
	data.frame(
		q = votes$q,
		SPls = votes$VPls / votes$q,
		SMns = votes$VMns / (1 - votes$q));
}