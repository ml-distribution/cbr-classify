package zx.soft.cbr.classify.core;

/**
 * 
 * @author wanggang
 *
 */
public class CaseSimilarityImpl implements ICaseSimilarity {

	private final double value;

	private final ICase baseCase;

	private final ICase similarCase;

	public CaseSimilarityImpl(double value, ICase baseCase, ICase similarCase) {
		this.value = value;
		this.baseCase = baseCase;
		this.similarCase = similarCase;
	}

	public double getValue() {
		return value;
	}

	public ICase getSimilarCase() {
		return similarCase;
	}

	public ICase getBaseCase() {
		return baseCase;
	}

	@Override
	public String toString() {
		return similarCase + "(" + value + ")";
	}

}
