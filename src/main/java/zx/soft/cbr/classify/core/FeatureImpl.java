package zx.soft.cbr.classify.core;

/**
 * 
 * @author wanggang
 *
 */
public class FeatureImpl implements IFeature {

	private final String attribute;

	private double weight;

	private double range;

	private boolean selected;

	public FeatureImpl(String attribute, double weight, double range) {
		this.attribute = attribute;
		this.weight = weight;
		this.range = range;
		this.selected = true;
	}

	public FeatureImpl(String attribute, boolean selected) {
		this.attribute = attribute;
		this.selected = selected;
	}

	public String getAttribute() {
		return attribute;
	}

	public double getWeight() {
		return weight;
	}

	public void setWeight(double weight) {
		this.weight = weight;
	}

	public double getRange() {
		return range;
	}

	public void setRange(double range) {
		this.range = range;
	}

	public boolean isSelected() {
		return selected;
	}

	public void setSelected(boolean selected) {
		this.selected = selected;
	}

	@Override
	public String toString() {
		return attribute + "(w:" + weight + " r:" + range + " s:" + selected + ")";
	}

}
