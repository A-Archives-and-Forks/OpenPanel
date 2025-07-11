import React from "react";
import {
    StrapiWithText,
    SupabaseWithText,
} from "@site/src/assets/integration-icons";
import { FooterDiscordIcon as DiscordIcon } from "../../refine-theme/icons/footer-discord";
import { FooterGithubIcon as GithubIcon } from "../../refine-theme/icons/footer-github";
import { FooterRedditIcon as RedditIcon } from "../../refine-theme/icons/footer-reddit";
import { FooterTwitterIcon as TwitterIcon } from "../../refine-theme/icons/footer-twitter";

// The contents added to the timeline are defined day by day in the data.timeline. All contents are not published at the same time.
// For unpublished contents, the link can be defined as null. If the link is set to null, the timeline item becomes disabled.
// If `publishDate` is defined, a countdown will be displayed for the timeline item.
// The format for `publishDate` is `YYYY-MM-DDTHH:mm+03:00` = `2023-06-20T13:00+03:00`.

const hashtags = "opensource";
const supabaseShareTweetURL = `https://twitter.com/intent/tweet?url=${encodeURIComponent(
    "https://refine.dev/week-of-refine-supabase/",
)}&text=${encodeURIComponent(
    `📚 RefineWeek ft Supabase: A week-long journey of building a complete CRUD app with @refine_dev and @supabase!\n\n`,
)}&hashtags=${hashtags}`;

const strapiShareTweetURL = `https://twitter.com/intent/tweet?url=${encodeURIComponent(
    "https://refine.dev/week-of-refine-strapi/",
)}&text=${encodeURIComponent(
    `📚 RefineWeek ft Strapi: A week-long journey of building a complete CRUD app with @refine_dev and @strapijs!\n\n`,
)}&hashtags=${hashtags}`;

export const data = {
    supabase: {
        logo: SupabaseWithText,
        cover: "/week-of-refine/supabase-cover.jpg",
        cover2x: "/week-of-refine/supabase-cover-2x.jpg",
        coverAlt: "refine week",
        title: "supabase",
        description:
            "Setup <strong>WHMCS & OpenPanel</strong> account provisioning in just 5 minutes.",
        date: "February 14 - February 20, 2023",
        timeline: [
            {
                date: "February 14, Monday",
                title: "Enable API access in OpenAdmin",
                description: `
                First make sure that API access is enabled by going to <strong className="font-bold">OpenAdmin > API</strong> or by running <strong className="font-bold">opencli config get api</strong> from the terminal.`,
                link: "https://openpanel.com/docs/articles/extensions/openpanel-and-whmcs/#enable-api",
                image: "/week-of-refine/supabase-timeline-1.jpg",
                image2x: "/week-of-refine/supabase-timeline-1-2x.jpg",
            },
            {
                date: "Februrary 15, Tuesday",
                title: "Whitelist on Firewall",
                description: `WHMCS server needs to be able to connect to OpenAdmin on port 2087, whitelist both servers: <strong className="font-bold">csf -a SERVER_IP</strong>.`,
                link: "https://openpanel.com/docs/articles/extensions/openpanel-and-whmcs/#whitelist-on-openpanel",
                image: "/week-of-refine/supabase-timeline-2.jpg",
                image2x: "/week-of-refine/supabase-timeline-2-2x.jpg",
            },
            {
                date: "Februrary 16, Wednesday",
                title: "Install OpenPanel Module",
                description: `SSH to your WHMCS server and inside <strong className="font-bold">path_to_whmcs/modules/servers</strong> run this command to download the module: <strong className="font-bold">git clone https://github.com/stefanpejcic/openpanel-whmcs-module.git openpanel</strong>.`,
                link: "https://openpanel.com/docs/articles/extensions/openpanel-and-whmcs/#install-openpanel-whmc-module",
                image: "/week-of-refine/supabase-timeline-3.jpg",
                image2x: "/week-of-refine/supabase-timeline-3-2x.jpg",
            },
            {
                date: "Februrary 17, Thursday",
                title: "Setup Server",
                description: `From WHMCS <strong className="font-bold">System Settings > Products & Services > Servers</strong> click on <strong className="font-bold">Create New Server</strong> and under module select <strong className="font-bold">openpanel</strong>  then add server IP, username and password for the OpenAdmin.`,
                link: "https://openpanel.com/docs/articles/extensions/openpanel-and-whmcs/#whmcs-module-setup",
                image: "/week-of-refine/supabase-timeline-4.jpg",
                image2x: "/week-of-refine/supabase-timeline-4-2x.jpg",
                enabledTime: "2023-06-21 12:30",
            },
            {
                date: "Februrary 18, Friday",
                title: "Create Hosting Plans",
                description: `Create a new group, then create new plans under this group. When creating products, make sure to select <strong className="font-bold">openpanel</strong> for Module and the newly created group`,
                link: "https://openpanel.com/docs/articles/extensions/openpanel-and-whmcs/#create-hosting-package-1",
                image: "/week-of-refine/supabase-timeline-5.jpg",
                image2x: "/week-of-refine/supabase-timeline-5-2x.jpg",
            },
            {
                date: "Februrary 19, Saturday",
                title: "Test",
                description: `Create a new order to test OpenAdmin API.`,
                link: "",
                image: "/week-of-refine/supabase-timeline-6.jpg",
                image2x: "/week-of-refine/supabase-timeline-6-2x.jpg",
            },
        ],
        shareTweetUrl: supabaseShareTweetURL,
        tweetIDList: [
            "1645507785621209097",
            "1635625661778763776",
            "1640741763408076803",
            "1625488050863353856",
            "1615260152822628352",
            "1621513516036526080",
            "1621932348009861132",
            "1597878371760979970",
            "1616390215068688384",
            "1617841995233529861",
            "1620724625536880641",
            "1618180208414322689",
        ],
    },
    strapi: {
        logo: StrapiWithText,
        cover: "/week-of-refine/strapi-cover.png",
        cover2x: "/week-of-refine/strapi-cover-2x.png",
        coverAlt: "Refine week",
        title: "strapi",
        description:
            "Setup <strong>FoSSBilling & OpenPanel</strong> account provisioning in just 5 minutes.",
        date: "April 10 - April 14, 2023",
        timeline: [
            {
                date: "April 10, Monday",
                title: "Pilot & Refine architecture",
                description: `Overview about <strong className="font-bold">Refine</strong> and <strong className="font-bold">Strapi</strong> the app we built during the article series.`,
                link: "https://refine.dev/blog/refine-react-invoice-generator-1/",
                image: "/week-of-refine/strapi-timeline-1.png",
                image2x: "/week-of-refine/strapi-timeline-1-2x.png",
            },
            {
                date: "April 11, Tuesday",
                title: "Setting Up the Invoicer App",
                description: `We start with setting up the Invoicer app using <strong className="font-bold">refine.new</strong> by choosing <strong className="font-bold">Ant Design</strong> as a UI framework and <strong className="font-bold">Strapi</strong> as a dataprovider`,
                link: "https://refine.dev/blog/refine-react-invoice-generator-2/",
                image: "/week-of-refine/strapi-timeline-2.png",
                image2x: "/week-of-refine/strapi-timeline-2-2x.png",
            },
            {
                date: "April 12, Wednesday",
                title: "Adding CRUD Actions & Views",
                description: `We leverage the Strapi dataProvider methods to implement CRUD operations for companies, clients and contacts resources. and user authentication using <strong className="font-bold">Strapi</strong>.`,
                link: "https://refine.dev/blog/refine-react-invoice-generator-3/",
                image: "/week-of-refine/strapi-timeline-3.png",
                image2x: "/week-of-refine/strapi-timeline-3-2x.png",
            },
            {
                date: "April 13, Thursday",
                title: "Creating Mission and Invoices Pages",
                description: `We add more CRUD views to the PDF Invoice Generator app we have been building using Refine and Strapi last few days.`,
                link: "https://refine.dev/blog/refine-react-invoice-generator-4/",
                image: "/week-of-refine/strapi-timeline-4.png",
                image2x: "/week-of-refine/strapi-timeline-4-2x.png",
            },
            {
                date: "April 14, Friday",
                title: "Adding PDF Renderer",
                description: `We come past the Refine features and add a pdf renderer to display our invoices in a PDF screen.`,
                link: "https://refine.dev/blog/refine-react-invoice-generator-5/",
                image: "/week-of-refine/strapi-timeline-5.png",
                image2x: "/week-of-refine/strapi-timeline-5-2x.png",
            },
        ],
        shareTweetUrl: strapiShareTweetURL,
        tweetIDList: [
            "1645507785621209097",
            "1635625661778763776",
            "1640741763408076803",
            "1625488050863353856",
            "1615260152822628352",
            "1621513516036526080",
            "1621932348009861132",
            "1597878371760979970",
            "1616390215068688384",
            "1617841995233529861",
            "1620724625536880641",
            "1618180208414322689",
            "1624015381403955200",
        ],
    },
};

export const additionalSources = [
    {
        title: "Join our",
        label: "Discord Server",
        icon: <DiscordIcon color="#5865F2" width="24" height="24" />,
        link: "https://discord.gg/refine",
        color: "#5865F2",
    },
    {
        title: "Visit our",
        label: "GitHub Repo",
        icon: (
            <GithubIcon
                className="text-gray-1000 dark:text-gray-0"
                width="24"
                height="24"
            />
        ),
        link: "https://github.com/refinedev/refine",
        color: "#242436",
    },
    {
        title: "Follow us on",
        label: "Twitter",
        icon: <TwitterIcon color="#00AAEC" width="24" height="24" />,
        link: "https://twitter.com/refine_dev",
        color: "#00AAEC",
    },
    {
        title: "Follow us on",
        label: "Reddit",
        icon: <RedditIcon color="#FF4500" width="24" height="24" />,
        link: "https://reddit.com/r/refine",
        color: "#FF4500",
    },
];

export type WeekVariants = keyof typeof data;
export type WeekData = (typeof data)[WeekVariants];
