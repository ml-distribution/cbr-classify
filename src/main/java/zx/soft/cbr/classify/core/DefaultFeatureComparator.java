package zx.soft.cbr.classify.core;

/**
 * 
 * @author wanggang
 *
 */
public class DefaultFeatureComparator implements IFeatureComparator {

	private IFeature feature;

	public DefaultFeatureComparator(IFeature feature) {
		this.feature = feature;
	}

	public double similar(Object object, Object object2) {
		double similarity = 0;
		if (object != null && object2 != null) {
			if (!object.getClass().equals(object2.getClass())) {
				throw new RuntimeException("No  possvel comparar objetos de tipos diferentes");
			}
			if (object instanceof Number) {
				double y0 = ((Number) object).doubleValue();
				double y1 = ((Number) object2).doubleValue();
				double d = Math.abs(y0 - y1);
				double range = getFeature().getRange();
				if (d == 0) {
					similarity = 1;
				} else if (d <= range) {
					similarity = 1 - (d / range);
				}
			} else if (object.equals(object2)) {
				similarity = 1;
			}
		}
		return similarity;
	}

	public IFeature getFeature() {
		return feature;
	}

	public void setFeature(IFeature feature) {
		this.feature = feature;
	}

}
