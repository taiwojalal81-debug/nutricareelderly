// lib/core/utils/food_details_enricher.dart

import 'package:flutter/material.dart';
import '../../domain/entities/nigerian_food_entity.dart';

class FoodEnrichment {
  final String imageUrl;
  final List<String> detailedRecipeSteps;
  final String seniorHealthBenefit;

  const FoodEnrichment({
    required this.imageUrl,
    required this.detailedRecipeSteps,
    required this.seniorHealthBenefit,
  });
}

class FoodDetailsEnricher {
  static final Map<String, FoodEnrichment> _enrichmentMap = {
    // Yoruba Dishes
    'Amala and Ewedu': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1627308595229-7830a5c91f9f?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Bring 3 cups of water to a boil in a clean, heavy-bottomed pot.',
        'Slowly sprinkle elubo (yam flour) into the boiling water while turning continuously with a wooden swallow stick.',
        'Knead and press the mixture firmly against the pot sides to smooth out all lumps until a soft stretch is formed.',
        'Add a splash of hot water, cover, and let it steam on low heat for 5 minutes to cook through.',
        'Knead vigorously once more until it is completely light and fluffy.',
        'Pick fresh ewedu leaves, wash them thoroughly in salt water to remove all dirt, and rinse under cold water.',
        'Boil the leaves in 1 cup of water with a pinch of cooking potash (Kan-un) for 5 minutes until very soft.',
        'Whisk the cooked leaves with a traditional short broom (Ijabe) or blend lightly for a smooth draw.',
        'Stir in ground crayfish, locust beans (Iru), and a pinch of low-sodium salt, then serve warm with the Amala.'
      ],
      seniorHealthBenefit: 'Yam flour is rich in slow-release carbohydrates, and Ewedu provides calcium and vitamin K to reinforce aging bones.',
    ),
    'Efo Riro': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Wash fresh shoko or spinach leaves thoroughly under cold water. Shred finely and squeeze dry to remove excess moisture.',
        'Boil clean red bell peppers, scotch bonnets, and onions, then blend coarsely (not smooth).',
        'Boil lean turkey breast or fresh fish with chopped onions, a small garlic clove, and fresh herbs until tender.',
        'Heat 1 tablespoon of red palm oil in a clean pot, and sauté sliced onions for 2 minutes.',
        'Add ground iru (locust beans) and the coarsely blended pepper mixture. Fry on medium heat for 10 minutes.',
        'Stir in the cooked turkey/fish pieces alongside a small splash of the savory cooking broth.',
        'Add a tablespoon of ground crayfish and simmer for 5 minutes until the stew is thick and fragrant.',
        'Fold in the shredded spinach leaves and stir thoroughly to coat them in the rich pepper sauce.',
        'Simmer uncovered on low heat for exactly 3 minutes, then remove from heat and serve warm.'
      ],
      seniorHealthBenefit: 'Steamed greens are high in mineral iron and antioxidants that protect aging eyes from macular degeneration.',
    ),
    'Gbegiri Soup': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Soak 2 cups of brown beans in warm water for 10 minutes, peel off the skins, and rinse thoroughly.',
        'Boil the peeled beans in a pot of unsalted water for 45 minutes until they are mushy and falling apart.',
        'Pass the cooked beans through a fine sieve or blend until perfectly smooth and creamy.',
        'Pour the bean puree back into a clean pot and place on medium-low heat.',
        'Stir in a splash of palm oil, ground crayfish, chopped onions, and a tiny pinch of salt.',
        'Simmer for 10 minutes, stirring frequently to prevent burning, until a velvety, rich soup forms.',
        'Serve hot alongside Ewedu and soft Amala swallow.'
      ],
      seniorHealthBenefit: 'Highly digestible plant protein and dietary fiber that support healthy bowel movements and heart function.',
    ),
    'Abula': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1627308595229-7830a5c91f9f?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Prepare smooth, soft Amala swallow from yam flour as described in the Amala recipe.',
        'Prepare a batch of draw-style Ewedu soup using fresh green leaves and locust beans.',
        'Prepare a pot of rich, golden Gbegiri bean soup.',
        'Prepare a savory Yoruba tomato stew with boiled mackerel or lean chicken.',
        'To assemble, shape the soft Amala swallow into a mound and place it in a wide ceramic serving bowl.',
        'Ladle the golden Gbegiri soup on one side of the Amala.',
        'Pour the green Ewedu draw soup directly over the Gbegiri.',
        'Top the entire dish with a spoonful of the savory red tomato stew and serve warm.'
      ],
      seniorHealthBenefit: 'Combines the bone-building nutrients of Ewedu with the heart-healthy dietary fiber of bean soup.',
    ),
    'Ofada Rice': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Pick dirt and stones from 1 cup of local unpolished Ofada brown rice thoroughly.',
        'Wash the brown rice under running water 3-4 times to clean it, then drain completely.',
        'Place the rice in a pot, add 3 cups of water, and boil on medium heat for 15 minutes.',
        'Drain the parboiled water completely to reduce the strong local aroma, and rinse the rice again.',
        'Pour 2 cups of fresh warm water into the pot, add a slice of onion, and cover tightly.',
        'Cook on low heat for 25 minutes until the unpolished rice grains are soft and fluffy.',
        'Let the pot steam covered off the burner for 5 minutes before serving warm with Ayamase stew.'
      ],
      seniorHealthBenefit: 'Retains all its natural whole-grain B vitamins and complex fiber to support blood sugar management.',
    ),
    'Ayamase Stew': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Blend fresh green bell peppers (Tatashe), green scotch bonnets, and onions coarsely.',
        'Boil the coarsely blended green puree in a pot on medium heat for 12 minutes to remove excess moisture.',
        'Heat 1.5 tablespoons of healthy vegetable oil in a pan, and sauté sliced onions and locust beans for 3 minutes.',
        'Stir in the concentrated green pepper paste, and fry on medium-low heat for 10 minutes.',
        'Add shredded boiled chicken breast or flaky boiled fish, and stir to coat.',
        'Drizzle a tablespoon of ground crayfish and simmer on low heat for 10 minutes until the stew is thick.',
        'Serve warm over soft boiled brown or Ofada rice.'
      ],
      seniorHealthBenefit: 'Prepared with minimal healthy oils, green bell peppers provide highly potent antioxidants for cellular repair.',
    ),
    'Ikokore (Ijebu Yam Porridge)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Peel fresh water yam thoroughly, wash, and grate finely into a smooth, thick paste.',
        'Mix a teaspoon of ground crayfish and a pinch of low-sodium salt into the grated water yam paste.',
        'In a medium pot, combine 2 cups of fish broth, a splash of palm oil, blended pepper, and crayfish.',
        'Bring the spiced broth to a full rolling boil on medium-high heat.',
        'Scoop the grated water yam paste in small, spoonful balls directly into the boiling broth.',
        'Do not stir immediately; cover the pot and let the yam balls cook and set for 10 minutes.',
        'Stir gently to break down a few yam balls to thicken the porridge into a rich, creamy sauce.',
        'Simmer on low heat for another 5 minutes, then serve warm.'
      ],
      seniorHealthBenefit: 'Water yam is highly digestible and possesses a low glycemic index, protecting seniors from blood glucose spikes.',
    ),
    'Dodo (Baking Ripe Plantain)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1564093490129-9685ab4cb877?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Select fully ripe yellow plantains that are soft to the touch with black spots on the skin.',
        'Peel the plantains and slice them diagonally into 1/2-inch thick pieces.',
        'Preheat your oven to 190°C (375°F) or preheat an air fryer to 180°C.',
        'Line a baking sheet with parchment paper, and arrange the sweet plantain slices in a single layer.',
        'Lightly brush each sweet slice with a tiny drop of healthy olive or coconut oil.',
        'Bake for 15 minutes (or air-fry for 12 minutes), flipping them halfway through.',
        'Remove when they are golden brown, caramelized, and soft to chew.',
        'Let cool slightly, then serve warm as a sweet, healthy side dish.'
      ],
      seniorHealthBenefit: 'Prepared using zero deep-frying to limit saturated fat intake, keeping blood vessels clear and healthy.',
    ),
    'Boli (Roasted Plantain)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Select firm, yellow ripe plantains or unripe plantains depending on preference.',
        'Peel the plantains, leaving them whole or cutting them lengthwise in half.',
        'Preheat your oven grill to 200°C (400°F) or prepare a clean stovetop grill pan.',
        'Place the plantains directly on the grill rack or pan, cooking on medium heat.',
        'Grill for 8-10 minutes, then turn them over to cook the other side.',
        'Continue grilling and turning until the plantains are golden-charred on the outside and tender inside.',
        'Serve hot with a side of lightly roasted peanuts or fresh vegetable sauce.'
      ],
      seniorHealthBenefit: 'An exceptional, slow-release carbohydrate source that is highly packed with potassium for blood pressure support.',
    ),
    'Ekuru (White Moi Moi)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1598449356475-b9f71db7d847?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Soak 2 cups of brown beans in warm water, peel off the skins, and wash thoroughly.',
        'Blend the peeled beans with a little water until the batter is exceptionally smooth and thick.',
        'Do not add salt, pepper, or oil. Pour the smooth paste into a mixing bowl.',
        'Whisk the batter vigorously with a wooden spoon for 8 minutes to trap air and make it fluffy.',
        'Pour the fluffy bean batter into heat-safe small ceramic bowls or wrap in clean leaves.',
        'Arrange in a steamer pot filled with an inch of boiling water, cover tightly, and steam for 30 minutes.',
        'Prepare a side sauce by frying blended red peppers and onions in olive oil with crayfish.',
        'Unwrap the soft steamed Ekuru, crumble it gently with a fork, and serve warm with the pepper sauce.'
      ],
      seniorHealthBenefit: 'Steamed legume dish that is entirely salt-free and oil-free, perfect for seniors managing hypertension.',
    ),
    'Ila Alase (Yoruba Okra)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Wash 15 fresh green okra pods thoroughly, slice off the ends, and chop finely.',
        'Bring 1.5 cups of fish or chicken broth to a gentle boil in a medium pot.',
        'Add a pinch of ground crayfish, locust beans (iru), and chopped red onions to the boiling broth.',
        'Stir in the chopped okra, and reduce the heat to medium.',
        'Simmer uncovered for exactly 3 minutes, stirring constantly to build a rich draw texture.',
        'Add fresh scent leaves or shredded pumpkin leaves (Ugu), and stir well.',
        'Cook for another 1 minute, then remove from heat and serve warm with soft swallows.'
      ],
      seniorHealthBenefit: 'Okra is extremely soft and easy to swallow, aiding digestive health and protecting the stomach lining.',
    ),
    'Iyan (Pounded Yam)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Peel white yam, slice into thick cubes, and wash thoroughly in clean cold water.',
        'Place yam cubes in a pot, cover with water, and boil on medium heat for 20 minutes without salt.',
        'Ensure the yams are completely soft and easy to pierce with a fork.',
        'Drain the water, reserving half a cup of the hot starchy yam water.',
        'Transfer the hot yam cubes to a food processor or wooden mortar.',
        'Pound or blend continuously until it is completely smooth, stretchy, and free of lumps.',
        'Add a splash of the reserved warm yam water if the dough is too stiff to make it exceptionally soft.',
        'Shape into smooth, warm mounds and serve immediately with fresh vegetable soup.'
      ],
      seniorHealthBenefit: 'A wholesome, naturally gluten-free carbohydrate source that is highly gentle on the stomach.',
    ),
    'Mosa (Sweet Plantain Puff)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1564093490129-9685ab4cb877?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Mash 2 over-ripe sweet plantains in a bowl with a fork until perfectly smooth.',
        'Stir in 1 cup of whole wheat flour, a teaspoon of yeast, and a tiny pinch of salt.',
        'Add a splash of warm water, and mix thoroughly into a thick batter.',
        'Cover the mixing bowl with a warm cloth and let the batter rise for 20 minutes.',
        'Preheat your oven to 180°C (350°F) or use a non-stick puff pan.',
        'Grease the pan cups lightly with olive oil, scoop in the batter, and bake for 12-15 minutes.',
        'Flip the sweet puffs halfway through to ensure they are golden brown and cooked through.',
        'Serve warm as a soft, sweet breakfast treat.'
      ],
      seniorHealthBenefit: 'Baked sweet plantain snack that avoids deep frying to protect vascular and cardiovascular wellness.',
    ),
    'Ojojo (Water Yam Fritters)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Peel water yam, wash thoroughly, and grate finely using the smallest holes of a grater.',
        'Add finely chopped red onions, green peppers, crayfish, and a tiny pinch of salt to the paste.',
        'Whisk the grated yam mixture vigorously with a spoon for 4 minutes to trap air.',
        'Preheat your oven to 190°C (375°F) or use a lightly greased non-stick skillet.',
        'Shape the mixture into small round balls and arrange on a baking sheet lined with parchment paper.',
        'Lightly spray or brush each ball with a drop of healthy olive oil.',
        'Bake for 18-20 minutes until the outside is golden-crisp and the inside is soft and fluffy.',
        'Serve warm as an easily chewable snack.'
      ],
      seniorHealthBenefit: 'Water yam is high in antioxidants and dietary fiber, promoting regular digestion and joint health.',
    ),
    'Eko (Cornstarch Jell)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Dissolve 1 cup of wet white Ogi/Akamu paste in 1 cup of cold water until smooth.',
        'Bring 3 cups of water to a rolling boil in a pot on high heat.',
        'Pour the boiling water slowly into the dissolved cornstarch paste while whisking continuously.',
        'Place the pot on low heat, and stir constantly for 5 minutes until the paste is cooked and translucent.',
        'Pour the hot, thick pudding into clean, traditional green leaves (Uma leaves) or small bowls.',
        'Fold the leaves neatly to wrap the pudding tightly, and let it cool completely.',
        'As it cools, the pudding will set into a firm, smooth, and gelatinous jelly.',
        'Serve cold or warm with fresh bean soup or vegetable stew.'
      ],
      seniorHealthBenefit: 'Extremely easy to chew, digest, and swallow, making it an excellent hydration and energy source.',
    ),

    // Igbo Dishes
    'Fufu and Oha Soup': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Prepare soft fufu swallow from cassava paste as described in standard swallow recipes.',
        'Wash fresh oha leaves carefully in clean cold water, then shred them gently using your fingers (do not use a knife).',
        'Boil fresh catfish or lean chicken breast in a pot with chopped onions and organic spices.',
        'Add 2 tablespoons of palm oil and 2 tablespoons of ground cocoyam paste (used as a thickener) to the pot.',
        'Stir in ground crayfish, yellow peppers, and locust beans (Ogiri Igbo) for a rich, authentic flavor.',
        'Simmer on medium heat for 10 minutes until the cocoyam paste dissolves completely, thickening the soup.',
        'Add the shredded oha leaves, and stir gently into the thick broth.',
        'Simmer on low heat for exactly 2 minutes to keep the leaves fresh and green, then serve warm.'
      ],
      seniorHealthBenefit: 'Oha leaves contain highly potent antioxidants and mineral calcium that soothe joint pain and protect bone density.',
    ),
    'Ofe Onugbu (Bitterleaf Soup)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Wash pre-washed bitterleaves repeatedly in warm water, squeezing them firmly to remove the bitter taste.',
        'Boil fresh fish or lean meat in a pot with chopped onions and organic spices until tender.',
        'Add cocoyam paste (thickener), palm oil, ground crayfish, yellow peppers, and Ogiri Igbo to the pot.',
        'Cook on medium heat for 12 minutes until the cocoyam dissolves, creating a smooth, thick broth.',
        'Stir in the washed bitterleaves, and mix thoroughly to combine.',
        'Simmer uncovered on medium-low heat for 10 minutes to allow the bitterleaves to soften and absorb the spices.',
        'Remove from heat and serve warm with a soft cassava swallow.'
      ],
      seniorHealthBenefit: 'Bitterleaf is historically celebrated for aiding digestion and helping regulate blood glucose levels.',
    ),
    'Okazi Soup': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Wash fresh okazi leaves and slice them into extremely thin, fine ribbons (or grind them lightly).',
        'Boil lean beef or fresh mackerel with sliced onions, yellow peppers, and crayfish until soft.',
        'Add palm oil, ground achi or cocoyam (thickener), and ground egusi seeds (optional) to the broth.',
        'Simmer on medium heat for 8 minutes until the soup thickens beautifully.',
        'Add the finely sliced okazi leaves and stir thoroughly.',
        'Simmer on low heat for 5 minutes until the okazi leaves are tender and easy to chew.',
        'Serve hot with your preferred soft swallowed food.'
      ],
      seniorHealthBenefit: 'Okazi is exceptionally rich in dietary fiber and essential minerals, support digestive regularity and cellular wellness.',
    ),
    'Abacha (African Salad)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1625938146369-adc83368bda7?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Soak dry shredded cassava (Abacha) in warm water for 5 minutes to soften, then drain completely.',
        'In a large mixing bowl, combine a splash of palm oil and a tiny pinch of edible potash (nzu) to create a yellow emulsion.',
        'Stir ground crayfish, chopped yellow peppers, Ogiri, and finely chopped onions into the palm oil mixture.',
        'Add the drained, soft cassava Abacha, and toss thoroughly until every shred is beautifully coated.',
        'Finely shred fresh garden egg leaves (Anara) and add them to the mixture for a fresh, healthy bite.',
        'Garnish with soft, boiled fresh fish chunks and sliced fresh garden eggs.',
        'Serve immediately at room temperature as a refreshing, light salad.'
      ],
      seniorHealthBenefit: 'Naturally gluten-free, highly hydrating, and prepared without cooking to preserve raw minerals and vitamins.',
    ),
    'Nkwobi (Soft Cow Foot)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Boil cow foot pieces in a pressure cooker with plenty of onions, ginger, and garlic for 45-60 minutes.',
        'Ensure the meat is completely tender, gelatinous, and exceptionally soft to chew.',
        'In a separate pot, mix a splash of palm oil with a tiny pinch of potash to form a warm, golden sauce.',
        'Stir ground crayfish, pepper, and ground ehu (calabash nutmeg) into the golden palm oil sauce.',
        'Toss the soft, cooked cow foot pieces directly into the warm sauce and mix thoroughly.',
        'Simmer on very low heat for 5 minutes so the meat absorbs the fragrant spices.',
        'Garnish with finely shredded fresh utazi leaves for a pleasant, warm, bitter finish and serve warm.'
      ],
      seniorHealthBenefit: 'An exceptional source of natural collagen to support joint elasticity and promote gut lining health.',
    ),
    'Ji Mmong (Igbo Yam Soup)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Peel white yam, slice into bite-sized cubes, and wash thoroughly in cold water.',
        'Place the yam cubes in a pot, add water to cover, and bring to a boil on medium heat.',
        'Add chopped onions, blended yellow pepper, ground crayfish, and a splash of palm oil.',
        'Cook for 15 minutes until the yam cubes are completely soft and easily pierced with a fork.',
        'Add fresh scent leaves (nchanwu) or shredded green pumpkin leaves (Ugu).',
        'Simmer on low heat for an additional 3 minutes, then serve warm in a soup bowl.'
      ],
      seniorHealthBenefit: 'Light, comforting, and incredibly soft, combining easily digestible carbs with iron from green leaves.',
    ),
    'Akpu (Igbo Fufu)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Peel cassava tubers, wash, and ferment in water for 3 days to soften completely.',
        'Filter the fermented pulp through a clean sieve to remove any remaining hard fibers.',
        'Pour the cassava pulp into a clean cotton bag and press tightly to squeeze out excess water.',
        'Shape the wet pulp into medium round balls, and place them in a pot of boiling water.',
        'Boil on high heat for 10-15 minutes until the outside of the balls turns slightly translucent.',
        'Remove the balls and knead them thoroughly in a wooden mortar or food processor.',
        'Return the smooth dough to the pot, add a splash of water, cover, and steam for 5 minutes.',
        'Knead once more until it is perfectly smooth, soft, and stretchy, then serve warm.'
      ],
      seniorHealthBenefit: 'A soft, easily swallowable food that is naturally gluten-free and highly filling.',
    ),
    'Okpa (Bambara Nut Cake)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1598449356475-b9f71db7d847?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Sift 2 cups of pure, fine Bambara nut flour into a large dry mixing bowl.',
        'Pour in 1 cup of warm water and stir continuously to prevent lumps from forming.',
        'Slowly stir in 2 tablespoons of warm red palm oil until the batter turns golden yellow.',
        'Stir in ground yellow peppers, finely chopped onions, and a tiny pinch of salt.',
        'The batter should be smooth and have a medium-thick, pourable consistency.',
        'Pour the golden batter into clean leaves or heat-safe small ceramic bowls.',
        'Steam on medium heat for 40-45 minutes. A toothpick inserted should come out clean.',
        'Let cool slightly, then serve warm as a soft, protein-rich breakfast cake.'
      ],
      seniorHealthBenefit: 'Packed with plant protein, minerals, and complex carbs that promote sustained, steady energy.',
    ),
    'Ugba (Oil Bean Salad)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1625938146369-adc83368bda7?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Rinse shredded, fermented African oil bean seeds (Ugba) in warm water and drain completely.',
        'In a clean pot, mix a splash of palm oil and a tiny pinch of potash to create a yellow emulsion.',
        'Add ground crayfish, chopped yellow peppers, Ogiri, and sliced onions to the warm emulsion.',
        'Add the fermented Ugba seeds and shredded stockfish pieces to the pot, tossing to combine.',
        'Warm the mixture on very low heat for exactly 5 minutes (do not cook or boil).',
        'Stir in finely shredded fresh green garden egg leaves (Anara).',
        'Garnish with red onions and serve warm at room temperature.'
      ],
      seniorHealthBenefit: 'Fermented beans provide beneficial probiotics that support digestion, gut immunity, and vascular health.',
    ),

    // Hausa Dishes
    'Tuwo Shinkafa': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Wash 1 cup of local soft short-grain rice (Shinkafar Tuwo) thoroughly under cold water.',
        'Place the rice in a pot, add 3 cups of water, and boil on medium heat without salt.',
        'Cook until the rice is completely overcooked, mushy, and very soft.',
        'Do not drain the water. Use a wooden swallow paddle (Muchi) to mash the soft rice thoroughly.',
        'Knead and press the rice against the pot sides until it forms a cohesive, smooth, and stretchy dough.',
        'Cover and let it steam on low heat for 3 minutes to set completely.',
        'Shape into soft, warm mounds, wrap in clean film, and serve hot with Miyan Taushe.'
      ],
      seniorHealthBenefit: 'Incredibly soft and easy to swallow, making it highly recommended for elderly individuals with chewing difficulties.',
    ),
    'Tuwo Masara': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1541832676-9b763b0239ab?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Bring 3 cups of fresh drinking water to a rolling boil in a heavy pot.',
        'Stir a half cup of white cornmeal with a little cold water to make a smooth, liquid paste.',
        'Pour the cornmeal paste slowly into the boiling water while whisking continuously to prevent lumps.',
        'Cook on medium heat for 5 minutes until the mixture thickens into a light porridge.',
        'Slowly add dry cornmeal powder while stirring vigorously with a wooden Muchi stick.',
        'Knead the dough firmly until it is perfectly smooth, thick, and elastic.',
        'Add a splash of hot water, cover, and let it steam on low heat for 5 minutes.',
        'Knead once more, then shape into smooth, warm mounds and serve hot.'
      ],
      seniorHealthBenefit: 'A wholesome, naturally gluten-free corn swallow that provides clean energy and dietary fiber.',
    ),
    'Miyan Kuka': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Boil fresh beef or fish with chopped onions, a small garlic clove, and fresh herbs until soft.',
        'Add a splash of palm oil, ground crayfish, yellow peppers, and locust beans (Daddawa).',
        'Let the seasoned broth boil vigorously on medium heat for 5 minutes.',
        'Reduce the heat to low.',
        'Slowly sprinkle green baobab leaf powder (Kuka powder) into the broth while whisking continuously.',
        'Use a wire whisk to ensure the powder blends smoothly into the broth without clumping.',
        'Simmer on low heat for exactly 5 minutes, stirring frequently, until a smooth draw soup forms.',
        'Serve hot alongside warm Tuwo Shinkafa.'
      ],
      seniorHealthBenefit: 'Baobab powder (Kuka) is extremely rich in Vitamin C, calcium, and antioxidants, boosting immunity.',
    ),
    'Miyan Taushe': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Peel ripe kabocha pumpkin, remove the seeds, and cut the orange flesh into small cubes.',
        'Boil the pumpkin cubes in a pot of water for 15 minutes until they are mushy and soft.',
        'Drain the water and mash the soft pumpkin flesh thoroughly into a smooth, thick puree.',
        'Boil lean chicken breast or fresh fish in another pot to create a rich, savory broth.',
        'Add the pumpkin puree, a splash of palm oil, ground peanuts (optional), and daddawa to the broth.',
        'Stir well and bring to a gentle simmer on medium-low heat.',
        'Stir in ground crayfish, yellow peppers, and chopped onions.',
        'Simmer for 10 minutes until the soup is thick and creamy.',
        'Add shredded fresh sorrel leaves (Yakuwa) or spinach, and simmer for another 3 minutes before serving.'
      ],
      seniorHealthBenefit: 'Pumpkin is exceptionally rich in vitamin A (beta-carotene) to protect aging eyesight and support cellular repair.',
    ),
    'Suya (Baked Lean Beef)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Select 300g of lean beef flank or chicken breast, and slice into very thin, wide ribbons.',
        'In a bowl, mix ground peanuts, ginger powder, garlic powder, onion powder, and a tiny pinch of cayenne.',
        'Generously coat each thin meat ribbon in the flavorful spice mix (Suya pepper).',
        'Preheat your oven to 180°C (350°F) or prepare a clean stovetop grill pan.',
        'Arrange the seasoned meat on a baking sheet lined with parchment paper.',
        'Bake for 12-15 minutes, flipping once, until the meat is fully cooked and slightly tender.',
        'Avoid overcooking to keep the meat easy to chew for seniors.',
        'Garnish with plenty of sliced fresh red onions and tomatoes, then serve warm.'
      ],
      seniorHealthBenefit: 'Baked using lean meats rather than open flame grilling to avoid carcinogens while providing high-quality protein.',
    ),
    'Masa (Wyna Rice Cakes)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1564093490129-9685ab4cb877?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Soak 2 cups of raw short-grain rice in water for 6 hours. Drain and set aside.',
        'Boil a half cup of the soaked rice until it is mushy and very soft.',
        'Blend the raw rice, cooked rice, a teaspoon of yeast, and warm water into a smooth, thick batter.',
        'Pour into a bowl, cover, and let it ferment in a warm place for 4-5 hours.',
        'Stir in finely chopped onions, a teaspoon of sugar (optional), and a tiny pinch of salt.',
        'Preheat a non-stick Masa pan (multi-cavity pan) on medium heat.',
        'Lightly brush each cavity with a drop of healthy olive or coconut oil.',
        'Pour in the batter, cook for 3 minutes, then flip over to cook the other side until golden and fluffy.'
      ],
      seniorHealthBenefit: 'Soft, easily chewable fermented rice cakes that provide highly accessible energy and support digestion.',
    ),
    'Dan Wake (Bean Dumplings)': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'In a bowl, mix 2 cups of brown bean flour with 1 teaspoon of potash water.',
        'Add a splash of warm water and mix thoroughly into a thick, smooth, and stretchy paste.',
        'Bring 4 cups of fresh water to a rolling boil in a wide pot.',
        'Shape the bean paste into small, bite-sized balls using your fingers or a spoon.',
        'Drop the balls directly into the boiling water.',
        'Cook on medium heat for 12-15 minutes. The dumplings will float to the top when fully cooked.',
        'Remove the dumplings using a slotted spoon and drop them into a bowl of cold water to cool.',
        'Drain and toss in a splash of olive oil, chopped onions, and a sprinkle of yaji spice before serving.'
      ],
      seniorHealthBenefit: 'Steam-boiled dumplings made entirely from bean flour, providing exceptional plant protein and zero fat.',
    ),

    // South-South Dishes
    'Banga Soup & Urhobo Starch': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Boil 500g of fresh palm fruits for 30 minutes until the skin is soft and easy to peel.',
        'Pound the warm fruits in a mortar to extract the rich oil, then rinse with warm water to create a palm concentrate.',
        'Pour the palm extract into a pot and boil on medium heat for 15 minutes to thicken.',
        'Add fresh catfish, chopped onions, yellow peppers, ground crayfish, and Banga spices (Beletete leaves).',
        'Simmer on medium-low heat for 10 minutes until the fish is flaky and tender.',
        'In a clean pot, dissolve 1 cup of cassava starch in 1.5 cups of cold water and a teaspoon of palm oil.',
        'Place on low heat and stir continuously with a wooden paddle until it thickens into a smooth, amber jelly.',
        'Serve the warm, soft Urhobo starch alongside the hot, savory Banga soup.'
      ],
      seniorHealthBenefit: 'Palm fruit extract provides natural vitamin E and carotenoids, while starch swallow is soft and easy to digest.',
    ),
    'Owo Soup & Plantain Swallow': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1541832676-9b763b0239ab?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Blend fresh tomatoes, sweet red peppers, yellow peppers, and onions into a smooth paste.',
        'Boil the blended puree in a pot on medium heat for 10 minutes to remove excess water.',
        'Stir in a splash of palm oil, ground crayfish, daddawa, and a pinch of potash water.',
        'The potash will emulsify the palm oil, turning the sauce a beautiful, velvety orange.',
        'Add fresh fish or boiled lean chicken chunks, and simmer on low heat for 8 minutes.',
        'In another pot, boil peeled green plantains until soft, then pound or blend into a smooth swallow.',
        'Serve the warm plantain swallow alongside the creamy, orange Owo soup.'
      ],
      seniorHealthBenefit: 'Plantain swallow is rich in dietary fiber and essential minerals, and Owo soup is incredibly smooth and easy to swallow.',
    ),
    'Fishermans Soup': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Clean fresh Tilapia, fresh prawns, and crab claws thoroughly, then place them in a wide pot.',
        'Add chopped onions, minced ginger, garlic, yellow pepper, and enough water to cover.',
        'Bring to a boil on medium heat for 8 minutes to create a fresh, light seafood broth.',
        'Stir in a splash of palm oil, ground crayfish, and a teaspoon of cocoyam paste to thicken.',
        'Add finely sliced fresh scent leaves (nchanwu) or uziza leaves for a warm, fragrant finish.',
        'Simmer gently on low heat for 5 minutes until the fish is flaky and the soup is slightly thick.',
        'Ladle the hot seafood and spiced broth into a wide bowl and serve warm.'
      ],
      seniorHealthBenefit: 'Omega-3 fatty acids from fresh seafood support brain health and help reduce joint inflammation.',
    ),
    'Afang Soup': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Grind dry or fresh okazi leaves in a blender or mortar until very fine.',
        'Wash fresh waterleaves thoroughly to remove sand, then shred finely.',
        'Boil lean meat or fresh fish in a pot with onions, peppers, and crayfish.',
        'Once the meat is tender, add palm oil, yellow peppers, and ground crayfish to the broth.',
        'Add the shredded waterleaf first and stir well. Let it simmer for 3 minutes.',
        'Fold in the ground okazi leaves and stir thoroughly to coat them in the rich broth.',
        'Simmer on low heat for exactly 5 minutes until the okazi leaves are soft and easy to chew.',
        'Remove from heat and serve warm with a soft swallow.'
      ],
      seniorHealthBenefit: 'Provides an abundance of mineral calcium, iron, and dietary fiber to protect aging bones and support gut health.',
    ),

    // Foreign Dishes
    'Oatmeal with Bananas': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1517686469429-8faf88b9f7af?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Bring 1.5 cups of fresh water or unsweetened almond milk to a gentle boil in a small pot.',
        'Stir in half a cup of rolled oats or quick-cooking oats, reducing the heat to medium-low.',
        'Cook for 5-7 minutes, stirring occasionally, until the oats are soft, creamy, and fully cooked.',
        'Remove the pot from the heat and let it sit covered for 2 minutes to thicken.',
        'Pour the warm, creamy oatmeal into a breakfast bowl.',
        'Slice half a ripe sweet banana into thin, bite-sized rounds.',
        'Arrange the banana slices beautifully on top of the warm oatmeal.',
        'Sprinkle a tiny pinch of cinnamon and drizzle a teaspoon of honey on top before serving warm.'
      ],
      seniorHealthBenefit: 'Beta-glucan fiber in oats actively helps lower cholesterol, while bananas provide essential potassium for blood pressure regulation.',
    ),
    'Spaghetti Bolognese': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Bring a large pot of water to a boil, and cook whole wheat spaghetti for 9 minutes until soft.',
        'In a non-stick pan, heat 1 tablespoon of olive oil, and sauté chopped onions and garlic for 2 minutes.',
        'Add 250g of lean minced chicken or turkey breast, and cook until browned, breaking it up.',
        'Pour in 1.5 cups of fresh tomato puree, 1 finely grated carrot, and a pinch of dried oregano.',
        'Simmer the savory tomato meat sauce on medium-low heat for 15 minutes until thick.',
        'Drain the spaghetti and toss with a drop of olive oil.',
        'Ladle the rich bolognese sauce over the soft pasta and serve warm.'
      ],
      seniorHealthBenefit: 'Whole wheat pasta provides excellent dietary fiber, and cooked tomatoes deliver heart-healthy lycopene.',
    ),
    'Coleslaw Salad': const FoodEnrichment(
      imageUrl: 'https://images.unsplash.com/photo-1625938146369-adc83368bda7?q=80&w=600&auto=format&fit=crop',
      detailedRecipeSteps: [
        'Finely shred half a head of fresh white cabbage and half a head of red cabbage.',
        'Grate 2 sweet carrots into thin ribbons, and place all vegetables in a salad bowl.',
        'In a side bowl, whisk 3 tablespoons of low-fat Greek yogurt, 1 teaspoon of apple cider vinegar, and 1 teaspoon of honey.',
        'Add a pinch of black pepper to the yogurt dressing, and pour over the salad.',
        'Toss thoroughly until every vegetable shred is beautifully coated.',
        'Chill in the refrigerator for 20 minutes to soften the cabbage, making it easier to chew.',
        'Serve cold as a refreshing, crunchy salad.'
      ],
      seniorHealthBenefit: 'Greek yogurt provides active probiotics to support digestion, and cabbage contains vitamins A, C, and K.',
    ),
  };

  static const Map<String, String> _imageMap = {
    'Amala and Ewedu': 'assets/images/amala_and_ewedu.jfif',
    'Efo Riro': 'assets/images/efo_riro.jpg',
    'Gbegiri Soup': 'assets/images/gbegiri_soup.jfif',
    'Abula': 'assets/images/abula.jfif',
    'Ofada Rice': 'assets/images/ofada_rice.jfif',
    'Ayamase Stew': 'assets/images/ayamase_stew_sauce.jfif',
    'Ikokore (Ijebu Yam Porridge)': 'assets/images/ikokore.jfif',
    'Dodo (Baking Ripe Plantain)': 'assets/images/dodo.jfif',
    'Boli (Roasted Plantain)': 'assets/images/boli.jfif',
    'Ekuru (White Moi Moi)': 'assets/images/ekuru.jfif',
    'Ila Alase (Yoruba Okra)': 'assets/images/ila_alasepo.jpg',
    'Iyan (Pounded Yam)': 'assets/images/iyan.jfif',
    'Ofada Stew': 'assets/images/ofada_rice.jfif',
    'Akara (Bean Cakes)': 'assets/images/akara.jpg',
    'Miyan Kuka': 'assets/images/iyan.jfif',
    'Miyan Taushe': 'assets/images/iyan.jfif',
    'Miyan Zogale (Moringa)': 'assets/images/iyan.jfif',
    'Miyan Tsire': 'assets/images/iyan.jfif',
    'Miyan Alayahu': 'assets/images/iyan.jfif',
    'Miyan Kubewa': 'assets/images/iyan.jfif',
    'Miyan Karkashi': 'assets/images/iyan.jfif',
  };


  static String getAuthenticFoodImageUrl(String foodName) {
    if (_imageMap.containsKey(foodName)) {
      return _imageMap[foodName]!;
    }
    final lowerName = foodName.toLowerCase();
    for (var entry in _imageMap.entries) {
      if (lowerName.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return 'assets/images/efo_riro.jfif';
  }

  static Widget buildFoodImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder != null 
          ? (context, err, stack) => errorBuilder(context, err, stack)
          : null,
      );
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'},
        errorBuilder: errorBuilder,
      );
    }
  }

  static Widget buildFoodImageWithFallback(
    String? databaseImageUrl,
    String foodName, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    final fallbackUrl = getEnrichment(foodName).imageUrl;
    
    if (databaseImageUrl != null && databaseImageUrl.isNotEmpty) {
      return buildFoodImage(
        databaseImageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return buildFoodImage(
            fallbackUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: errorBuilder,
          );
        },
      );
    }
    
    return buildFoodImage(
      fallbackUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }

  static FoodEnrichment getEnrichment(String foodName) {
    for (var entry in _enrichmentMap.entries) {
      if (foodName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(foodName.toLowerCase())) {
        return FoodEnrichment(
          imageUrl: getAuthenticFoodImageUrl(foodName),
          detailedRecipeSteps: entry.value.detailedRecipeSteps,
          seniorHealthBenefit: entry.value.seniorHealthBenefit,
        );
      }
    }
    // Fallback
    return FoodEnrichment(
      imageUrl: getAuthenticFoodImageUrl(foodName),
      detailedRecipeSteps: const [
        'Wash all ingredients thoroughly under clean running water.',
        'Chop the fresh vegetables and lean proteins into small, chewable, bite-sized pieces.',
        'Boil or steam the ingredients to avoid excess oil and preserve natural vitamins.',
        'Season with fresh herbs, ginger, and garlic rather than high-sodium salt seasonings.',
        'Cook on medium-low heat until completely soft and easy to chew.',
        'Serve freshly made and warm with plenty of clean drinking water.'
      ],
      seniorHealthBenefit: 'Provides fresh, wholesome nutrients prepared using healthy, low-fat cooking methods to support active longevity.',
    );
  }

  /// PROGRAMMATIC SEEDER GENERATOR FOR EXACTLY 150 HEALTHY MEALS
  /// 30 Yoruba, 30 Igbo, 30 Hausa, 30 South-South, 30 Foreign
  static List<NigerianFoodEntity> getSeededFoods() {
    final List<NigerianFoodEntity> seededList = [];

    // Ethnic categories
    final tribes = ['Yoruba', 'Igbo', 'Hausa', 'South-South', 'Foreign'];

    // 30 distinct dishes per category
    final Map<String, List<String>> dishesMap = {
      'Yoruba': [
        'Amala and Ewedu', 'Efo Riro', 'Gbegiri Soup', 'Abula', 'Ofada Rice',
        'Ayamase Stew', 'Ikokore (Ijebu Yam Porridge)', 'Dodo (Baking Ripe Plantain)', 'Boli (Roasted Plantain)', 'Ekuru (White Moi Moi)',
        'Ila Alase (Yoruba Okra)', 'Iyan (Pounded Yam)', 'Mosa (Sweet Plantain Puff)', 'Ojojo (Water Yam Fritters)', 'Eko (Cornstarch Jell)',
        'Ewedu Soup', 'Dun Dun (Yams)', 'Beske (Soya Wara)', 'Gurudi (Coconut Biscuits)', 'Ofada Stew',
        'Yoruba Steamed Corn (Asaro)', 'Akara (Bean Cakes)', 'Adun Yoruba', 'Efo Shoko', 'Efo Tete',
        'Yoruba Fried Beans (Ewa Agoyin)', 'Ewa Alagbado', 'Elubo Swallow', 'Ila Soup', 'Yoruba Egusi Stew'
      ],
      'Igbo': [
        'Fufu and Oha Soup', 'Ofe Onugbu (Bitterleaf Soup)', 'Okazi Soup', 'Abacha (African Salad)', 'Nkwobi (Soft Cow Foot)',
        'Ji Mmong (Igbo Yam Soup)', 'Akpu (Igbo Fufu)', 'Okpa (Bambara Nut Cake)', 'Ugba (Oil Bean Salad)', 'Ofe Achara',
        'Ofe Akwu (Banga Soup)', 'Ji Frayi (Baked Yam)', 'Garden Egg Sauce', 'Tapioca Swallow', 'Ukwa (Breadfruit Porridge)',
        'Ayaraya Ji (Mashed Yam)', 'Ofe Owerri', 'Ofe Nsala (White Soup)', 'Ofe Shalau', 'Ofe Nsala Fish',
        'Ofe Di Na Mba', 'Ofe Ujuju', 'Achicha (Dried Cocoyam)', 'Ofe Okra Igbo', 'Ofe Ugbogiri',
        'Ofe Egusi Igbo', 'Mgbam (Igbo Patty)', 'Ji Abana Swallow', 'Ofe Okazi Stew', 'Ofe Utazi'
      ],
      'Hausa': [
        'Tuwo Shinkafa', 'Tuwo Masara', 'Miyan Kuka', 'Miyan Taushe', 'Suya (Baked Lean Beef)',
        'Kilishi (Beef Jerky)', 'Masa (Wyna Rice Cakes)', 'Dan Wake (Bean Dumplings)', 'Fura da Nono', 'Gurasa (Hausa Flatbread)',
        'Alkaki (Hausa Sweet)', 'Dubulan', 'Pate (Hausa Porridge)', 'Gwate (Hausa Grain Soup)', 'Miyan Zogale (Moringa)',
        'Kosai (Hausa Akara)', 'Kunun Gyada', 'Kunun Zaki', 'Kunun Aya (Tiger Nut Milk)', 'Miyan Tsire',
        'Shinkafa da Wake', 'Tuwon Semovita', 'Miyan Alayahu', 'Sinasir (Rice Pancakes)', 'Sinasir Special',
        'Balangu (Soft Roasted Meat)', 'Nama da Tsire', 'Miyan Kubewa', 'Wara (Hausa Tofu)', 'Miyan Karkashi'
      ],
      'South-South': [
        'Banga Soup & Urhobo Starch', 'Owo Soup & Plantain Swallow', 'Fishermans Soup', 'Afang Soup', 'Edikang Ikong Soup',
        'Ekpang Nkukwo', 'Atama Soup', 'Peppersoup Calabar', 'Ukodo (Yam Peppersoup)', 'Bole and Grilled Fish',
        'Calabar Smart Salad', 'Native Rice Calabar', 'Iwuk Ukom (Plantain Mash)', 'Ofe Ujuju South', 'Eba and Okra Soup',
        'Edit Yond', 'Onunu (Yam & Plantain)', 'Peppersoup Chicken South', 'Periwinkle Soup', 'Snails in Pepper South',
        'Banga Rice Delta', 'Ofe Uziza South', 'Native Pasta South', 'Seafood Okra Soup', 'Seafood Fried Rice South',
        'Isiewu (Goat Head Mash)', 'Delta Banga Stew', 'Rivers Native Rice', 'Urhobo Starch Swallow', 'Ogoja Bean Mash'
      ],
      'Foreign': [
        'Oatmeal with Bananas', 'Spaghetti Bolognese', 'Coleslaw Salad', 'Egg Fried Rice', 'Chicken Salad',
        'Oat Pancakes', 'Grilled Salmon with Veggies', 'Wholewheat French Toast', 'Vegetable Stir Fry', 'Lean Beef Burger',
        'Healthy Potato Salad', 'Tuna Salad Sandwich', 'Greek Salad', 'Mashed Sweet Potatoes', 'Chicken Curry with Brown Rice',
        'Healthy Macaroni and Cheese', 'Soft Scrambled Eggs', 'Caesar Salad with Grilled Chicken', 'Baked Beans on Toast', 'Garlic Herb Bread',
        'Tomato Basil Soup', 'Minestrone Vegetable Soup', 'Beef Fried Rice with Peas', 'Healthy Shepherd\'s Pie', 'Turkey Club Sandwich',
        'Fresh Fruit Salad', 'Herb Roasted Chicken', 'Pancake Butter Oats', 'Healthy Spaghetti Carbonara', 'Low-fat Grilled Cheese'
      ]
    };

    // Suitability mappings
    final conditionSuitability = {
      'Yoruba': ['Hypertension', 'Osteoarthritis'],
      'Igbo': ['Diabetes', 'Osteoarthritis'],
      'Hausa': ['Hypertension', 'Diabetes'],
      'South-South': ['Diabetes', 'Obesity'],
      'Foreign': ['Hypertension', 'Obesity', 'Diabetes']
    };

    int globalIndex = 1;

    for (final tribe in tribes) {
      final dishes = dishesMap[tribe]!;
      final suitableConditions = conditionSuitability[tribe]!;

      for (int i = 0; i < dishes.length; i++) {
        final dishName = dishes[i];
        final id = 'seeded-food-${globalIndex}';

        // Categorize roughly into breakfast (first 10), lunch (next 10), dinner (last 10)
        String category = 'breakfast';
        if (i >= 10 && i < 20) category = 'lunch';
        if (i >= 20) category = 'dinner';

        // Custom nutritional parameters
        final double calories = 250.0 + (i * 8.5) % 250;
        final double protein = 8.0 + (i * 2.5) % 25;
        final double carbs = 30.0 + (i * 4.5) % 60;
        final double fat = 5.0 + (i * 1.5) % 15;
        final double fiber = 3.0 + (i * 0.8) % 10;
        final int potassium = 200 + (i * 25) % 500;
        final int sodium = 40 + (i * 12) % 180;

        // Try to fetch custom enrichment details
        final enrichment = getEnrichment(dishName);

        seededList.add(
          NigerianFoodEntity(
            id: id,
            foodName: dishName,
            description: 'A delicious, healthy, senior-friendly ${tribe} dish prepared with wholesome ingredients.',
            portionSizeGrams: 200,
            caloriesPerPortion: double.parse(calories.toStringAsFixed(1)),
            proteinG: double.parse(protein.toStringAsFixed(1)),
            carbsG: double.parse(carbs.toStringAsFixed(1)),
            fatG: double.parse(fat.toStringAsFixed(1)),
            fiberG: double.parse(fiber.toStringAsFixed(1)),
            potassiumMg: potassium,
            sodiumMg: sodium,
            suitableForConditions: suitableConditions,
            mealCategory: category,
            ethnicity: tribe,
            recipe: enrichment.detailedRecipeSteps.join('\n'),
            imageUrl: enrichment.imageUrl,
          ),
        );

        globalIndex++;
      }
    }

    return seededList;
  }
}
