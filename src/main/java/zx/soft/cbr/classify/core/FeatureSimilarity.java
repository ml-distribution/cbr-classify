package zx.soft.cbr.classify.core;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import zx.soft.cbr.classify.utils.Accessor;
import zx.soft.cbr.classify.utils.AccessorUtil;

/**
 * 
 * @author wanggang
 *
 */
@SuppressWarnings({ "unchecked", "rawtypes", "unused" })
public class FeatureSimilarity implements ISimilarityAlgorithm {

	public Set<ICaseSimilarity> getSimilarity(ICase theCase, Set<ICase> similarCases, double threshold,
			Object... params) {
		Set<ICaseSimilarity> cases = null;
		Collection<IFeature> features = null;
		if (params != null) {
			features = (Collection<IFeature>) params[0];
		}
		if (features == null) {
			features = getAllFeatures(theCase);
		}
		if (!features.isEmpty()) {
			double maxScore = 0;
			for (IFeature feature : features) {
				if (feature.isSelected()) {
					try {
						if (AccessorUtil.invokeGetter(feature.getAttribute(), theCase) != null) {
							maxScore += feature.getWeight();
						}
					} catch (Exception e) {
						throw new RuntimeException(e);
					}
				}
			}
			if (similarCases != null && !similarCases.isEmpty()) {
				cases = new HashSet();
				for (ICase aCase : similarCases) {
					double caseScore = 0;
					for (IFeature feature : features) {
						if (feature.isSelected()) {
							caseScore += getScore(feature, theCase, aCase);
						}
					}
					double similarity = caseScore * 100 / maxScore;
					if (similarity >= threshold) {
						cases.add(new CaseSimilarityImpl(similarity, theCase, aCase));
					}
				}
			}
		} else {
			throw new RuntimeException("No foram selecionadas caractersticas a analisar");
		}
		return cases;
	}

	private Set<IFeature> getAllFeatures(ICase theCase) {
		Set<IFeature> features = new HashSet<IFeature>();
		for (Accessor accessor : AccessorUtil.getAccessorsList(theCase.getClass())) {
			features.add(new FeatureImpl(accessor.getName(), 1, 0));
		}
		return features;
	}

	private double getScore(IFeature feature, ICase theCase, ICase aCase) {
		Accessor acc = AccessorUtil.getAccessor(feature.getAttribute(), theCase.getClass());
		double value;
		try {
			IFeatureComparator fc = null;
			FeatureComparator annotation = acc.getGetter().getAnnotation(FeatureComparator.class);
			if (annotation != null) {
				fc = (IFeatureComparator) annotation.value().newInstance();
			} else {
				fc = new DefaultFeatureComparator(feature);
			}
			return fc.similar(acc.invokeGetter(theCase), acc.invokeGetter(aCase)) * feature.getWeight();
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

}
