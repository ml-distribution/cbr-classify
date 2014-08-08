package zx.soft.cbr.classify.core;

/**
 * 
 * @author wanggang
 *
 */
public interface IFeature {

	public String getAttribute();

	public double getWeight();

	public double getRange();

	public boolean isSelected();

}
