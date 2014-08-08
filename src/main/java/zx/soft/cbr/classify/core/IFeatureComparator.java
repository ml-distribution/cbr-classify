package zx.soft.cbr.classify.core;

/**
 * 
 * @author wanggang
 *
 */
public interface IFeatureComparator {

	public IFeature getFeature();

	public double similar(Object object, Object object2);

}
