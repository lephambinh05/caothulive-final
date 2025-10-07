const { db } = require('./firebase-admin-config');

const seedData = async () => {
  try {
    console.log('🌱 Starting Firestore seed...');

    // Seed YouTube Links
    const youtubeLinksRef = db.collection('youtube_links');
    const existingLinks = await youtubeLinksRef.get();
    
    if (existingLinks.empty) {
      console.log('📝 Seeding YouTube Links...');
      
      const links = [
        {
          title: 'HACKINTOSH DUAL BOOT - macOS + Windows',
          url: 'https://www.youtube.com/watch?v=jNQXAC9IVRw',
          priority: 1,
          created_at: new Date(),
          is_active: true
        },
        {
          title: 'Video Demo 2 - Sắp phát',
          url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          priority: 2,
          created_at: new Date(Date.now() + 86400000), // Tomorrow
          is_active: true
        },
        {
          title: 'Video Demo 3 - Đã kết thúc',
          url: 'https://www.youtube.com/watch?v=9bZkp7q19f0',
          priority: 3,
          created_at: new Date(Date.now() - 86400000), // Yesterday
          is_active: false
        }
      ];

      for (const link of links) {
        await youtubeLinksRef.add(link);
      }
      
      console.log('✅ YouTube Links seeded successfully!');
    } else {
      console.log('ℹ️ YouTube Links collection already has data. Skipping seed.');
    }

    // Seed YouTube Channels
    const youtubeChannelsRef = db.collection('youtube_channels');
    const existingChannels = await youtubeChannelsRef.get();
    
    if (existingChannels.empty) {
      console.log('📺 Seeding YouTube Channels...');
      
      const channels = [
        {
          channel_id: 'UC_x5XG1J2SeiVu9MXFPRc8g',
          channel_name: 'Google Developers',
          channel_url: 'https://www.youtube.com/channel/UC_x5XG1J2SeiVu9MXFPRc8g',
          avatar_url: 'https://yt3.ggpht.com/ytc/AGIKgqNq6zUDrD2CwHbu0utR4P7OViYjL9LcF6VQ2w=s176-c-k-c0x00ffffff-no-rj',
          description: 'Google Developers channel with latest tech updates',
          subscriber_count: 1500000,
          video_count: 2500,
          created_at: new Date(),
          is_active: true
        },
        {
          channel_id: 'UCBJycsmduvYEL83R_U4JriQ',
          channel_name: 'Marques Brownlee',
          channel_url: 'https://www.youtube.com/channel/UCBJycsmduvYEL83R_U4JriQ',
          avatar_url: 'https://yt3.ggpht.com/ytc/AGIKgqNq6zUDrD2CwHbu0utR4P7OViYjL9LcF6VQ2w=s176-c-k-c0x00ffffff-no-rj',
          description: 'Tech reviews and smartphone analysis',
          subscriber_count: 18000000,
          video_count: 1200,
          created_at: new Date(),
          is_active: true
        }
      ];

      for (const channel of channels) {
        await youtubeChannelsRef.add(channel);
      }
      
      console.log('✅ YouTube Channels seeded successfully!');
    } else {
      console.log('ℹ️ YouTube Channels collection already has data. Skipping seed.');
    }

    console.log('🎉 Firestore seeding completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding Firestore:', error);
    process.exit(1);
  }
};

seedData();
