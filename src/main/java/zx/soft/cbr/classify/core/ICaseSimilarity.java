package zx.soft.cbr.classify.core;

/**
 * 
 * @author wanggang
 *
 */
public interface ICaseSimilarity {

	public double getValue();

	public ICase getSimilarCase();

	public ICase getBaseCase();

}
